import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { existsSync, mkdirSync, mkdtempSync, readFileSync, readdirSync, realpathSync, rmSync, statSync, symlinkSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { test } from 'node:test';

const script = resolve(import.meta.dirname, '../tools/check-instruction-context.ps1');

function fixture(t) {
  const temp = mkdtempSync(join(realpathSync(tmpdir()), 'maitre-instructions-'));
  t.after(() => rmSync(temp, { recursive: true, force: true }));
  const global = join(temp, 'profil privé');
  const root = join(temp, 'projet été');
  const middle = join(root, 'module 空');
  const leaf = join(middle, 'niveau é');
  const cwd = join(leaf, 'session finale');
  mkdirSync(cwd, { recursive: true });
  mkdirSync(global);
  const manifest = join(temp, 'sélection locale.json');
  const config = {
    client: 'codex-cli',
    cwd,
    global_dir: global,
    project_root: root,
    project_doc_max_bytes: 7,
    project_doc_fallback_filenames: ['guide équipe.md', 'backup.md'],
  };
  function writeManifest() {
    writeFileSync(manifest, JSON.stringify(config), 'utf8');
  }
  function run() {
    writeManifest();
    return readReport();
  }
  function readReport(manifestPath = manifest) {
    const result = spawnSync('pwsh', ['-NoProfile', '-File', script, '-ManifestPath', manifestPath], {
      cwd: temp, encoding: 'utf8', timeout: 30_000,
    });
    if (result.error) throw result.error;
    assert.equal(result.stderr, '');
    return { exitCode: result.status, report: JSON.parse(result.stdout), stdout: result.stdout };
  }
  return { temp, global, root, middle, leaf, cwd, config, manifest, writeManifest, run, readReport };
}

function treeSnapshot(directory) {
  return readdirSync(directory, { withFileTypes: true }).map(entry => {
    const path = join(directory, entry.name);
    const metadata = statSync(path);
    return [entry.name, metadata.mtimeMs, entry.isDirectory() ? treeSnapshot(path) : readFileSync(path).toString('hex')];
  });
}

test('separate global selection, blank project override and cumulative UTF-8 project budget', t => {
  const f = fixture(t);
  writeFileSync(join(f.global, 'AGENTS.override.md'), ' \t\n');
  writeFileSync(join(f.global, 'AGENTS.md'), 'contenu global privé'.repeat(4));
  writeFileSync(join(f.root, 'AGENTS.md'), 'éé');
  writeFileSync(join(f.middle, 'AGENTS.override.md'), '');
  writeFileSync(join(f.middle, 'AGENTS.md'), 'texte masqué');
  writeFileSync(join(f.leaf, 'guide équipe.md'), 'xyé');
  writeFileSync(join(f.leaf, 'backup.md'), 'texte de repli masqué');
  writeFileSync(join(f.cwd, 'AGENTS.md'), 'dernier niveau');
  writeFileSync(join(f.temp, 'AGENTS.md'), 'hors chaîne');
  f.writeManifest();
  const before = treeSnapshot(f.temp);

  const { exitCode, report, stdout } = f.readReport('./sélection locale.json');
  assert.equal(exitCode, 0);
  assert.equal(report.status, 'SIMULATED');
  assert.equal(report.configuration_effective, 'UNVERIFIED');
  assert.equal(report.session_load, 'UNVERIFIED');
  assert.equal(report.manual_reference, 'NOT_ASSESSED');
  assert.equal(report.project_budget_bytes, 7);
  assert.equal(report.project_remaining_bytes, 0);
  assert.deepEqual(report.candidates.map(row => [row.scope, row.level, row.candidate, row.state, row.budget_bytes, row.truncated]), [
    ['global', 0, 'override', 'EMPTY', null, null],
    ['global', 0, 'standard', 'INCLUDED', null, null],
    ['project', 0, 'standard', 'INCLUDED', 4, false],
    ['project', 1, 'override', 'EMPTY', 0, false],
    ['project', 1, 'standard', 'MASKED', null, null],
    ['project', 2, 'fallback_1', 'INCLUDED', 3, true],
    ['project', 2, 'fallback_2', 'MASKED', null, null],
    ['project', 3, 'standard', 'SKIPPED_BUDGET', 0, null],
  ]);
  assert.ok(!/projet été|guide équipe|contenu global|texte masqué|session finale/.test(stdout));
  assert.deepEqual(treeSnapshot(f.temp), before);
});

test('declared cwd-only, zero and custom budget and fallback order override any inferred defaults', t => {
  const f = fixture(t);
  f.config.project_root = null;
  f.config.project_doc_max_bytes = 0;
  f.config.project_doc_fallback_filenames = ['guide équipe.md', 'backup.md'];
  writeFileSync(join(f.global, 'AGENTS.override.md'), 'override global');
  writeFileSync(join(f.global, 'AGENTS.md'), 'base globale omise');
  writeFileSync(join(f.root, 'AGENTS.md'), 'fichier parent exclu');
  writeFileSync(join(f.cwd, 'guide équipe.md'), 'ok');
  writeFileSync(join(f.cwd, 'backup.md'), 'b');
  writeFileSync(join(f.global, 'config.toml'), 'project_doc_max_bytes = 32768');
  const { report } = f.run();
  assert.equal(report.project_root, 'CWD_ONLY');
  assert.equal(report.project_budget_bytes, 0);
  assert.deepEqual(report.candidates.map(row => [row.candidate, row.state]), [
    ['override', 'INCLUDED'], ['standard', 'MASKED'], ['fallback_1', 'SKIPPED_BUDGET'], ['fallback_2', 'MASKED'],
  ]);

  f.config.project_doc_max_bytes = 2;
  f.config.project_doc_fallback_filenames.reverse();
  const updated = f.run().report;
  assert.equal(updated.project_remaining_bytes, 1);
  assert.equal(updated.candidates[2].file_bytes, 1);
  assert.equal(updated.candidates[2].state, 'INCLUDED');
});

test('a truncated whitespace-only prefix consumes no project budget and still masks alternatives', t => {
  const f = fixture(t);
  f.config.project_doc_max_bytes = 2;
  f.config.project_doc_fallback_filenames = [];
  writeFileSync(join(f.root, 'AGENTS.override.md'), '  texte');
  writeFileSync(join(f.root, 'AGENTS.md'), 'base');
  writeFileSync(join(f.cwd, 'AGENTS.md'), 'ok');
  const { report } = f.run();
  assert.deepEqual(report.candidates.map(row => [row.state, row.budget_bytes, row.truncated]), [
    ['EMPTY', 0, true], ['MASKED', null, null], ['INCLUDED', 2, false],
  ]);
});

test('invalid UTF-8 contributes its raw byte count in the local project budget', t => {
  const f = fixture(t);
  f.config.project_doc_max_bytes = 3;
  writeFileSync(join(f.global, 'AGENTS.override.md'), Buffer.from([0xff]));
  writeFileSync(join(f.global, 'AGENTS.md'), 'base');
  writeFileSync(join(f.root, 'AGENTS.md'), Buffer.from([0xff]));
  writeFileSync(join(f.cwd, 'AGENTS.md'), 'é');
  const { report } = f.run();
  assert.equal(report.project_remaining_bytes, 0);
  assert.deepEqual(report.candidates.map(row => [row.state, row.budget_bytes]), [
    ['INCLUDED', null], ['MASKED', null], ['INCLUDED', 1], ['INCLUDED', 2],
  ]);
});

test('retains distinct Unicode fallback names on filesystems that distinguish them', t => {
  const f = fixture(t);
  const composed = 'é.md';
  const decomposed = 'e\u0301.md';
  f.config.project_doc_fallback_filenames = [composed, decomposed];
  writeFileSync(join(f.cwd, decomposed), 'ok');
  if (existsSync(join(f.cwd, composed))) {
    t.skip('filesystem identifies canonically equivalent names');
    return;
  }
  const { report } = f.run();
  assert.deepEqual(report.candidates.map(row => [row.candidate, row.state]), [['fallback_2', 'INCLUDED']]);
});

test('a Unix FIFO cannot mask a regular project file', { skip: process.platform === 'win32' }, t => {
  const f = fixture(t);
  const fifo = join(f.cwd, 'AGENTS.override.md');
  const created = spawnSync('mkfifo', [fifo], { encoding: 'utf8', timeout: 5_000 });
  if (created.error) throw created.error;
  assert.equal(created.status, 0, created.stderr);
  f.config.project_doc_fallback_filenames = ['guide "équipe".md'];
  writeFileSync(join(f.leaf, f.config.project_doc_fallback_filenames[0]), 'a');
  writeFileSync(join(f.cwd, 'AGENTS.md'), 'ok');
  const { report } = f.run();
  assert.deepEqual(report.candidates.map(row => [row.candidate, row.state]), [
    ['fallback_1', 'INCLUDED'], ['standard', 'INCLUDED'],
  ]);
});

test('an unknown root, fallback list or budget cannot produce a complete simulation', t => {
  const f = fixture(t);
  writeFileSync(join(f.root, 'AGENTS.md'), 'un niveau parent');
  writeFileSync(join(f.cwd, 'AGENTS.md'), 'un niveau courant');
  for (const field of ['project_root', 'project_doc_max_bytes', 'project_doc_fallback_filenames']) {
    const previous = f.config[field];
    delete f.config[field];
    const { report } = f.run();
    assert.equal(report.status, 'PARTIAL');
    assert.equal(report.project_remaining_bytes, null);
    assert.ok(report.candidates.every(row => row.state === 'SELECTED_BUDGET_UNKNOWN'));
    if (field === 'project_root') {
      assert.equal(report.project_root, 'UNKNOWN');
      assert.equal(report.candidates.length, 1);
    }
    if (field === 'project_doc_fallback_filenames') assert.equal(report.project_fallbacks, 'UNKNOWN');
    if (field === 'project_doc_max_bytes') assert.equal(report.project_budget_bytes, null);
    f.config[field] = previous;
  }
});

test('rejects traversal, redirected directories and private paths without leaking their values', t => {
  const f = fixture(t);
  f.config.project_doc_fallback_filenames = ['../fichier-de-confidentialité'];
  let result = f.run();
  assert.equal(result.exitCode, 1);
  assert.equal(result.report.code, 'INVALID_PATH_SEGMENT');
  assert.ok(!result.stdout.includes('fichier-de-confidentialité'));

  f.config.project_doc_fallback_filenames = [];
  f.config.project_root = f.global;
  result = f.run();
  assert.equal(result.report.code, 'ROOT_OUTSIDE_CWD_CHAIN');
  assert.ok(!result.stdout.includes('profil privé'));

  const redirected = join(f.temp, 'répertoire redirigé');
  symlinkSync(f.global, redirected, process.platform === 'win32' ? 'junction' : 'dir');
  f.config.project_root = f.root;
  f.config.global_dir = redirected;
  result = f.run();
  assert.equal(result.exitCode, 1);
  assert.equal(result.report.code, 'REDIRECTED_PATH');
  assert.ok(!result.stdout.includes('répertoire redirigé'));

  const rawNetworkPath = '\\\\exemple-interdit\\privé\\manifeste.json';
  result = f.readReport(rawNetworkPath);
  assert.equal(result.exitCode, 1);
  assert.equal(result.report.code, 'LOCAL_PATH_REQUIRED');
  assert.ok(!result.stdout.includes('exemple-interdit'));

  if (process.platform !== 'win32') {
    f.config.global_dir = f.global;
    const linked = join(f.global, 'AGENTS.override.md');
    symlinkSync(f.manifest, linked, 'file');
    assert.equal(f.run().report.code, 'REDIRECTED_PATH');
  }
});

test('bad JSON and wrong manifest field types give bounded output', t => {
  const f = fixture(t);
  writeFileSync(f.manifest, '{"privé":"valeur à ne pas divulguer"');
  const malformed = f.readReport();
  assert.equal(malformed.exitCode, 1);
  assert.equal(malformed.report.code, 'DIAGNOSTIC_UNAVAILABLE');
  assert.ok(!malformed.stdout.includes('divulguer'));

  f.config.project_doc_max_bytes = '32768';
  assert.equal(f.run().report.code, 'INVALID_PROJECT_BUDGET');
  f.config.project_doc_max_bytes = 7;
  f.config.project_doc_fallback_filenames = 'guide équipe.md';
  assert.equal(f.run().report.code, 'INVALID_FALLBACK_LIST');
});

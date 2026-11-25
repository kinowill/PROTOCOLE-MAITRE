import { mkdtempSync, mkdirSync, writeFileSync, readFileSync, rmSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { tmpdir } from 'node:os';
import { join, resolve, sep } from 'node:path';
import { spawnSync } from 'node:child_process';
const repo = resolve(import.meta.dirname, '..');
const tempRoot = resolve(tmpdir());
const tmp = mkdtempSync(join(tempRoot, 'protocole-tests-'));
const git = process.platform === 'win32' ? 'git.exe' : 'git';
const pwsh = process.platform === 'win32' ? 'pwsh.exe' : 'pwsh';
const audit = join(repo, 'tools', 'pre-push-audit.ps1');
const check = join(repo, 'tools', 'install-check.ps1');
let failures = 0;
let checks = 0;
function run(cmd, args, cwd = tmp) {
  const result = spawnSync(cmd, args, { cwd, encoding: 'utf8', timeout: 30000 });
  if (result.error) throw result.error;
  return result;
}
function expect(ok, message) {
  checks++;
  if (!ok) failures++;
  console.log((ok ? 'OK ' : 'FAIL ') + message);
}
function stage(path) {
  if (run(git, ['add', '--', path]).status !== 0) throw new Error('git add failed');
}
function scan(path = tmp, extra = []) {
  return run(pwsh, ['-NoProfile', '-File', audit, '-Path', path, ...extra]);
}
function verify(target, source) {
  return run(pwsh, ['-NoProfile', '-File', check, '-Target', target, ...(source ? ['-Source', source] : [])]);
}
try {
  expect(run(git, ['init', '-q']).status === 0, 'git init');
  const fixture = join(tmp, 'fixture.txt');
  writeFileSync(fixture, 'ordinary text'); stage('fixture.txt');
  expect(scan().status === 0, 'clean tracked content');
  const families = [
    'AK' + 'IA' + 'A'.repeat(16), 'AI' + 'za' + 'B'.repeat(35),
    'gh' + 'p_' + 'C'.repeat(36), 'gh' + 'o_' + 'D'.repeat(36),
    'github' + '_pat_' + 'E'.repeat(30), 'sk' + '-' + 'F'.repeat(30),
    '-----BEGIN ' + 'RSA PRIVATE KEY-----', 'password' + ' = "synthetic-test-value"',
  ];
  for (let i = 0; i < families.length; i++) {
    const fake = families[i];
    writeFileSync(fixture, fake); stage('fixture.txt'); writeFileSync(fixture, 'ordinary text');
    const result = scan();
    expect(result.status === 1, 'synthetic secret family ' + (i + 1) + ' in index');
    expect(!(result.stdout + result.stderr).includes(fake), 'secret remains redacted ' + (i + 1));
  }
  writeFileSync(fixture, 'ordinary text'); stage('fixture.txt'); writeFileSync(fixture, families[0]);
  expect(scan().status === 1, 'secret in worktree');
  writeFileSync(fixture, 'ordinary text');
  for (const flag of ['--assume-unchanged', '--skip-worktree']) {
    expect(run(git, ['update-index', flag, 'fixture.txt']).status === 0, 'set fixture index flag ' + flag);
    writeFileSync(fixture, families[0]);
    expect(scan().status === 2, 'hidden worktree flag fails closed ' + flag);
    writeFileSync(fixture, 'ordinary text');
    if (run(git, ['update-index', flag.replace('--', '--no-'), 'fixture.txt']).status !== 0) throw new Error('Cannot reset fixture index flag');
  }
  writeFileSync(fixture, families[0]);
  const child = join(tmp, 'nested [folder]'); mkdirSync(child);
  expect(scan(child).status === 1, 'subdirectory scan covers repository root');
  writeFileSync(fixture, 'ordinary text');
  const binary = join(tmp, 'binary.dat'); writeFileSync(binary, Buffer.from('\0' + families[0] + '\0')); stage('binary.dat');
  expect(scan().status === 1, 'binary tracked content is scanned');
  writeFileSync(binary, 'ordinary text'); stage('binary.dat');
  const literal = 'literal.[test]+(value)';
  writeFileSync(fixture, literal);
  expect(scan(tmp, ['-ExtraPatterns', literal]).status === 1, 'extra strings matched literally');
  writeFileSync(fixture, 'literalXtestvalue');
  expect(scan(tmp, ['-ExtraPatterns', literal]).status === 0, 'extra strings are not regexes');
  writeFileSync(fixture, 'ordinary text');
  const notRepo = mkdtempSync(join(tempRoot, 'protocole-no-git-'));
  try { expect(scan(notRepo).status === 2, 'non-repository fails closed'); }
  finally { rmSync(notRepo, { recursive: true, force: true }); }
  expect(scan(join(tmp, 'missing')).status === 2, 'missing scan directory fails closed');
  const target = join(tmp, 'AGENTS [test].md');
  const sourcePath = join(repo, 'NOYAU.md');
  const source = readFileSync(sourcePath, 'utf8');
  writeFileSync(target, 'Local instructions\n\n' + source + '\n');
  const valid = verify(target);
  expect(valid.status === 0, 'complete kernel with local instructions');
  const report = valid.status === 0 && JSON.parse(valid.stdout.slice(0, valid.stdout.indexOf('}') + 1));
  expect(report.statut === 'OK_STATIQUE' && report.chargement_session === 'NON_VERIFIE' && report.occurrences === 1, 'static report preserves status and session distinction');
  const sha256 = (path) => createHash('sha256').update(readFileSync(path)).digest('hex').toUpperCase();
  expect(report.source_sha256 === sha256(sourcePath) && report.target_sha256 === sha256(target), 'report hashes correspond to raw source and target bytes');
  expect(!(valid.stdout + valid.stderr).includes(tmp) && !valid.stdout.includes('"source":') && !valid.stdout.includes('"target":'), 'no absolute personal paths in report');
  const sourceWithoutFinalNewlines = source.replace(/(?:\r?\n)+$/, '');
  writeFileSync(target, 'Local instructions\n\n' + sourceWithoutFinalNewlines + '\nOther local instructions');
  expect(verify(target).status === 0, 'local instructions on either side accepted');
  writeFileSync(target, sourceWithoutFinalNewlines);
  expect(verify(target).status === 0, 'kernel ending at EOF accepted');
  writeFileSync(target, sourceWithoutFinalNewlines + ' additional instructions\n');
  expect(verify(target).status === 1, 'suffix on kernel final line rejected');
  writeFileSync(target, sourceWithoutFinalNewlines + ' \n');
  expect(verify(target).status === 1, 'trailing space on kernel final line rejected');
  writeFileSync(target, source + '\n' + source);
  expect(verify(target).status === 1, 'duplicate kernel rejected');
  writeFileSync(target, source.slice(0, 100));
  expect(verify(target).status === 1, 'truncated kernel rejected');
  const sourcePatch = join(tmp, 'source.md');
  const patched = source.replace(/Noyau v\d+\.\d+\.\d+/, 'Noyau v9.8.7');
  writeFileSync(sourcePatch, patched); writeFileSync(target, patched);
  expect(verify(target, sourcePatch).status === 0, 'major.minor.patch recognized');
  writeFileSync(target, patched.replace('v9.8.7', 'v9.8.6'));
  expect(verify(target, sourcePatch).status === 1, 'different patch version rejected');
  const incomplete = patched.replace('v9.8.7', 'v9.8');
  writeFileSync(sourcePatch, incomplete); writeFileSync(target, incomplete);
  expect(verify(target, sourcePatch).status === 1, 'incomplete source version rejected');
  writeFileSync(sourcePatch, patched);
  writeFileSync(target, patched + '\n' + source);
  expect(verify(target, sourcePatch).status === 1, 'conflicting old kernel rejected');
  writeFileSync(target, source.replace(/\r?\n/g, '\r\n'));
  expect(verify(target).status === 0, 'CRLF/LF equivalents accepted');
  writeFileSync(target, '\uFEFF' + source);
  expect(verify(target).status === 0, 'UTF-8 BOM accepted');
  const utf16 = Buffer.concat([Buffer.from([0xff, 0xfe]), Buffer.from(source, 'utf16le')]);
  writeFileSync(target, utf16);
  expect(verify(target).status === 1, 'UTF-16 BOM target rejected');
  writeFileSync(target, Buffer.concat([Buffer.from(source), Buffer.from([0xff])]));
  const encodingError = verify(target);
  expect(encodingError.status === 1 && !(encodingError.stdout + encodingError.stderr).includes(tmp), 'invalid UTF-8 target fails without exposing path');
  // Keep the UTF-16 source below the kernel budget to exercise decoding.
  const compactKernel = source.split(/\r?\n/, 1)[0] + '\n\nRègle locale.\n';
  writeFileSync(sourcePatch, Buffer.concat([Buffer.from([0xff, 0xfe]), Buffer.from(compactKernel, 'utf16le')]));
  writeFileSync(target, compactKernel);
  expect(verify(target, sourcePatch).status === 1, 'UTF-16 BOM source rejected within byte budget');
  writeFileSync(sourcePatch, '\uFEFF' + compactKernel);
  expect(verify(target, sourcePatch).status === 0, 'UTF-8 BOM source accepted within byte budget');
  writeFileSync(target, source.replace('1. **', '1.  **'));
  expect(verify(target).status === 1, 'kernel content edits rejected');
  writeFileSync(sourcePatch, source.split(/\r?\n/, 1)[0] + '\n');
  writeFileSync(target, readFileSync(sourcePatch));
  expect(verify(target, sourcePatch).status === 1, 'source header without kernel body rejected');
  writeFileSync(sourcePatch, '');
  expect(verify(target, sourcePatch).status === 1, 'empty source rejected');
  writeFileSync(sourcePatch, source + 'x'.repeat(3072)); writeFileSync(target, readFileSync(sourcePatch));
  expect(verify(target, sourcePatch).status === 1, 'source beyond 3 KiB rejected');
  const missing = verify(join(tmp, 'missing'));
  expect(missing.status === 1 && !(missing.stdout + missing.stderr).includes(tmp), 'missing target fails without exposing path');
} finally {
  if (!resolve(tmp).startsWith(tempRoot + sep)) throw new Error('Unsafe temporary cleanup path');
  rmSync(tmp, { recursive: true, force: true });
}
console.log((checks - failures) + '/' + checks + ' checks passed');
if (failures) process.exitCode = 1;

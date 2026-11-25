import assert from 'node:assert/strict';
import { mkdtempSync, mkdirSync, readFileSync, writeFileSync, unlinkSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve, sep } from 'node:path';
import { spawnSync } from 'node:child_process';

const repo = resolve(import.meta.dirname, '..');
const tempRoot = resolve(tmpdir());
const fixture = mkdtempSync(join(tempRoot, 'maitre-validate-'));
const git = process.platform === 'win32' ? 'git.exe' : 'git';
const pwsh = process.platform === 'win32' ? 'pwsh.exe' : 'pwsh';
function gitRun(args) {
  const result = spawnSync(git, args, { cwd: fixture, encoding: 'utf8' });
  assert.equal(result.status, 0, 'Fixture Git command failed');
  return result.stdout;
}
function validate({ legacyConsole = false } = {}) {
  const script = join(repo, 'tools', 'validate.ps1');
  const args = legacyConsole
    ? ['-Command', '[Console]::OutputEncoding = [Text.Encoding]::Latin1; & $env:PROTOCOLE_TEST_VALIDATOR -Path $env:PROTOCOLE_TEST_REPO']
    : ['-File', script, '-Path', fixture];
  const env = { ...process.env, PROTOCOLE_TEST_VALIDATOR: script, PROTOCOLE_TEST_REPO: fixture };
  const result = spawnSync(pwsh, ['-NoProfile', ...args], { encoding: 'utf8', env, timeout: 30000 });
  if (result.error) throw result.error;
  return result;
}
try {
  gitRun(['init', '-q']);
  gitRun(['config', 'core.autocrlf', 'true']);
  const ignoreFile = join(fixture, '.git', 'fixture-excludes');
  writeFileSync(ignoreFile, '');
  gitRun(['config', 'core.excludesFile', ignoreFile]);
  const corePath = join(fixture, 'NOYAU.md');
  const core = readFileSync(join(repo, 'NOYAU.md'));
  // Exercise the byte limit even if a later canonical kernel is shorter.
  const budgetKernel = Buffer.concat([core, Buffer.alloc(3072 - core.length, 0x0a)]);
  writeFileSync(corePath, budgetKernel);
  writeFileSync(join(fixture, '.gitignore'), '.opencode-local/\n');
  const referencePath = join(fixture, 'PROTOCOLE.md');
  const reference = readFileSync(join(repo, 'PROTOCOLE.md'), 'utf8');
  writeFileSync(referencePath, reference);
  const adapters = process.platform === 'win32' ? 'INTEGRATIONS' : 'integrations';
  mkdirSync(join(fixture, adapters));
  for (const adapter of ['opencode', 'harness-dsh', 'codex', 'claude-code', 'generic']) writeFileSync(join(fixture, adapters, adapter + '.md'), '# Adapter\n');
  gitRun(['add', '.']);
  unlinkSync(corePath);
  gitRun(['checkout-index', '-f', '--', 'NOYAU.md']);
  assert.ok(readFileSync(corePath).length > 3072, 'control reproduces CRLF budget failure');
  console.log('OK control reproduces CRLF checkout byte-budget failure');
  writeFileSync(join(fixture, '.gitattributes'), readFileSync(join(repo, '.gitattributes')));
  gitRun(['add', '.gitattributes']);
  unlinkSync(corePath);
  gitRun(['checkout-index', '-f', '--', 'NOYAU.md']);
  assert.deepEqual(readFileSync(corePath), budgetKernel, 'core must retain LF under autocrlf=true');
  console.log('OK LF checkout preserves kernel budget with autocrlf=true');
  if (process.platform === 'win32') {
    const hidden = spawnSync('attrib.exe', ['+H', join(fixture, '.gitattributes')], { encoding: 'utf8' });
    assert.equal(hidden.status, 0, 'Cannot mark fixture metadata hidden');
  }
  assert.equal(validate().status, 0, 'tracked hidden metadata must be readable');
  console.log('OK tracked hidden metadata included in validation');
  const header = core.toString('utf8').split(/\r?\n/, 1)[0];
  for (const [invalid, label] of [
    ['', 'empty kernel'],
    [header + '\n\n', 'header without kernel body'],
    [core.toString('utf8').replace(/Noyau v\d+\.\d+\.\d+/, 'Noyau v9.8'), 'incomplete kernel version'],
  ]) {
    writeFileSync(corePath, invalid);
    assert.equal(validate().status, 1, label + ' must fail validation');
    console.log('OK rejected ' + label);
  }
  writeFileSync(corePath, core);
  writeFileSync(referencePath, Array.from({ length: 16 }, (_, i) => '## Section ' + i).join('\n'));
  assert.equal(validate().status, 1, 'unrelated headings cannot replace required sections');
  console.log('OK heading count cannot replace required sections');
  const headings = reference.match(/^## .+$/gm);
  writeFileSync(referencePath, ['```markdown', ...headings, '```', ''].join('\n'));
  assert.equal(validate().status, 1, 'headings in a fenced example cannot replace required sections');
  console.log('OK headings in code examples do not satisfy required sections');
  writeFileSync(referencePath, reference + '\n## Préambule\n');
  assert.equal(validate().status, 1, 'a required title must occur only once');
  console.log('OK duplicate required heading rejected');
  writeFileSync(referencePath, reference + '\n~~~markdown\n## Préambule\n~~~\n');
  assert.equal(validate().status, 0, 'a heading in a fenced example is a valid citation');
  console.log('OK fenced heading citation accepted');
  writeFileSync(referencePath, reference);
  const adapterPath = join(fixture, adapters, 'generic.md');
  writeFileSync(adapterPath, '# Adapter\n\nLe client affiche « approbation obligatoire » lorsque la politique interdit une opération.\n');
  const citation = validate();
  assert.equal(citation.status, 0, 'client permission terminology must not make an adapter invalid');
  assert.match(citation.stdout, /AVERTISSEMENT/, 'normative vocabulary still prompts review');
  console.log('OK legitimate permission terminology prompts review without failing validation');
  writeFileSync(adapterPath, '# Adapter\n\n' + core.toString('utf8'));
  assert.equal(validate().status, 1, 'an adapter must not duplicate the kernel');
  console.log('OK embedded kernel rejected in adapter');
  writeFileSync(adapterPath, '# Adapter\n');
  const addedAdapter = join(fixture, adapters, 'new-client.md');
  writeFileSync(addedAdapter, '# Adapter\n\n' + core.toString('utf8'));
  assert.ok(gitRun(['ls-files', '--others', '--exclude-standard', '-z']).split('\0').includes(adapters + '/new-client.md'), 'fixture adapter must appear in Git inventory');
  const invalidAdapter = validate();
  assert.equal(invalidAdapter.status, 1, 'a new non-ignored adapter is covered by structural checks');
  assert.match(invalidAdapter.stdout, /du noyau repris dans integrations\/new-client\.md/);
  console.log('OK untracked adapter validated');
  unlinkSync(addedAdapter);
  mkdirSync(join(fixture, '.opencode-local'));
  writeFileSync(join(fixture, '.opencode-local', 'broken.ps1'), 'function {');
  assert.equal(validate().status, 0, 'ignored private scripts must not enter repository validation');
  console.log('OK ignored private files excluded from validation');
  const pending = join(fixture, 'pending.ps1');
  writeFileSync(pending, 'function {');
  assert.equal(validate().status, 1, 'new non-ignored script must be validated');
  console.log('OK untracked relevant files validated');
  unlinkSync(pending);
  const unicodeFile = join(fixture, 'élève.md');
  writeFileSync(unicodeFile, '# Texte UTF-8\n');
  assert.equal(validate({ legacyConsole: true }).status, 0, 'valid Unicode file works with a legacy console encoding');
  console.log('OK valid Unicode filename accepted with a legacy console encoding');
  writeFileSync(unicodeFile, Buffer.from([0xff]));
  assert.equal(validate().status, 1, 'new file with a Unicode name must be validated');
  console.log('OK file with Unicode name validated');
  const invalidUnicode = validate({ legacyConsole: true });
  assert.equal(invalidUnicode.status, 1, 'Git path decoding must be independent of the console encoding');
  assert.match(invalidUnicode.stdout, /UTF-8 invalide/);
  console.log('OK Unicode paths validated independently of console encoding');
  unlinkSync(unicodeFile);
  const hiddenInvalid = join(fixture, '.invalid.md');
  writeFileSync(hiddenInvalid, Buffer.from([0xff, 0xfe, 0xff]));
  if (process.platform === 'win32') {
    const hidden = spawnSync('attrib.exe', ['+H', hiddenInvalid], { encoding: 'utf8' });
    assert.equal(hidden.status, 0, 'Cannot mark invalid fixture hidden');
  }
  assert.equal(validate().status, 1, 'invalid hidden file must fail validation');
  console.log('OK invalid hidden UTF-8 rejected');
} finally {
  if (!resolve(fixture).startsWith(tempRoot + sep)) throw new Error('Unsafe fixture cleanup');
  rmSync(fixture, { recursive: true, force: true });
}

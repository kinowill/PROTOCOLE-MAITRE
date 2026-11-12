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
}
function validate() {
  const result = spawnSync(pwsh, ['-NoProfile', '-File', join(repo, 'tools', 'validate.ps1'), '-Path', fixture], { encoding: 'utf8', timeout: 30000 });
  if (result.error) throw result.error;
  return result;
}
try {
  gitRun(['init', '-q']);
  gitRun(['config', 'core.autocrlf', 'true']);
  const core = readFileSync(join(repo, 'NOYAU.md'));
  writeFileSync(join(fixture, 'NOYAU.md'), core);
  writeFileSync(join(fixture, '.gitignore'), '.opencode-local/\n');
  writeFileSync(join(fixture, 'PROTOCOLE.md'), Array.from({ length: 15 }, (_, i) => '## Section ' + i).join('\n'));
  mkdirSync(join(fixture, 'integrations'));
  for (const adapter of ['opencode', 'harness-dsh', 'codex', 'claude-code', 'generic']) writeFileSync(join(fixture, 'integrations', adapter + '.md'), '# Adapter\n');
  gitRun(['add', '.']);
  unlinkSync(join(fixture, 'NOYAU.md'));
  gitRun(['checkout-index', '-f', '--', 'NOYAU.md']);
  assert.ok(readFileSync(join(fixture, 'NOYAU.md')).length > 3072, 'control reproduces CRLF budget failure');
  console.log('OK control reproduces CRLF checkout byte-budget failure');
  writeFileSync(join(fixture, '.gitattributes'), readFileSync(join(repo, '.gitattributes')));
  gitRun(['add', '.gitattributes']);
  unlinkSync(join(fixture, 'NOYAU.md'));
  gitRun(['checkout-index', '-f', '--', 'NOYAU.md']);
  assert.deepEqual(readFileSync(join(fixture, 'NOYAU.md')), core, 'core must retain LF under autocrlf=true');
  console.log('OK LF checkout preserves kernel budget with autocrlf=true');
  mkdirSync(join(fixture, '.opencode-local'));
  writeFileSync(join(fixture, '.opencode-local', 'broken.ps1'), 'function {');
  assert.equal(validate().status, 0, 'ignored private scripts must not enter repository validation');
  console.log('OK ignored private files excluded from validation');
  const pending = join(fixture, 'pending.ps1');
  writeFileSync(pending, 'function {');
  assert.equal(validate().status, 1, 'new non-ignored script must be validated');
  console.log('OK untracked relevant files validated');
  unlinkSync(pending);
  writeFileSync(join(fixture, 'invalid.md'), Buffer.from([0xff, 0xfe, 0xff]));
  assert.equal(validate().status, 1, 'invalid UTF-8 must fail');
  console.log('OK invalid UTF-8 rejected');
} finally {
  if (!resolve(fixture).startsWith(tempRoot + sep)) throw new Error('Unsafe fixture cleanup');
  rmSync(fixture, { recursive: true, force: true });
}

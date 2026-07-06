# Claude Review Workflow Prompts

> Reusable workflow templates only. This file does not own or state the
> Current Active Goal; `docs/TASKS.md` remains authoritative.

## Four-Stage Pipeline

1. Claude Developer implements.
2. The same Claude thread performs Developer Self-Check.
3. A new independent Claude thread performs read-only Pre-Audit.
4. Codex performs Final Audit and repository operations.

Any source or test change invalidates the prior Self-Check and Pre-Audit.

## Prompt A — Claude Developer Self-Check

Copy this into the existing Developer thread after implementation:

```text
你现在从 Claude Developer 切换为 Claude Developer Self-Check。
这是同一开发线程的候选清理门，不是独立审计，也不是最终验收。

项目目录：
/Users/poon/Library/CloudStorage/GoogleDrive-zeronxpbee@gmail.com/我的云端硬盘/Codex/projects/codexbar-fork-ark

目标：
对你刚完成的候选实现做完整自查。发现问题时在既有授权范围内直接修复，
使用 additive commit；直到候选满足 SELF-CHECK PASS 才停止。

开始前必须：
1. 使用或明确对照 LOOP Skill。
2. 读取项目 AGENTS.md、docs/TASKS.md、当前里程碑的
   docs/PROJECT_LOG.md 记录，以及 TASKS 引用的决策/审计 Entry。
3. 读取 upstream baseline 规则：
   git show 6ab1cbb7daee73b8ad531fbdd420e9aa6eb6d26b:AGENTS.md
4. 核验真实 branch、HEAD、parent、worktree、index 和锁状态。
5. 以 TASKS 的 Active Goal、allowed/forbidden scope、Definition of Done
   为准，不依赖聊天中的旧状态。

Self-Check 范围：
A. Git / scope
- 候选必须 additive；禁止 amend/reset/rebase/history rewrite。
- 检查完整 active-task diff，不只检查最后一个 commit。
- changed files 必须全部在 TASKS 授权范围。
- worktree/index 最终必须 clean。

B. Mechanical gate
- git diff --check
- 项目固定 SwiftFormat / SwiftLint（只检查相关 changed Swift files）
- swift build
- TASKS 指定的 focused tests
- make check（若 TASKS 或 final-candidate policy 要求）
- 仅在 milestone-final/dependency/global change 时运行 make test；
  已确认且未变化的外部 blocker 只引用既有 Entry。
- 工具链不存在或命令不能运行时写 NOT RUN，并说明原因；不得推断 PASS。

C. Judgment self-review
- 每项需求都有实现和测试证据。
- 无无关 provider、M2/M3/M5、Widget/global architecture 或共享触点漂移。
- 无真实 AK/SK、Authorization、RequestId、cookie、原始敏感响应或 config。
- 错误、missing、unknown、stale、兼容性和 rollback 行为符合 TASKS。
- UI 任务在环境支持时必须准备确定性尺寸的渲染证据；环境不支持时写
  Visual evidence: NOT RUN，并明确留给 Codex Final Audit，不能声称视觉 PASS。
- 文档中的测试数量、命令结果、SHA 和限制必须与现场一致。

发现问题时：
- 在授权范围内修复并创建新的 additive corrective commit。
- 修复后从 Git/scope、mechanical、judgment 三部分重新完整自查。
- 如果需要新 shared touchpoint、架构改变、产品取舍或越过 TASKS，
  立即 stop-and-report 给 Bee，不自行扩大范围。

禁止：
- push、PR、merge、release、branch/worktree/remotes 操作。
- 临时 GIT_INDEX_FILE、绕过锁、覆盖他人文件。
- 把自己的 Self-Check 称作独立审计或最终 PASS。

最终只输出以下紧凑交接：

Candidate SHA:
Parent SHA:
Branch:
Changed files:
SELF-CHECK: PASS
Commands/results:
- <command>: PASS / FAIL / NOT RUN
Scope/security review: PASS
Visual evidence: PASS / NOT RUN
Known limitations:
Worktree/index: CLEAN

如果无法达到 PASS，输出 SELF-CHECK: BLOCKED，并给出唯一明确阻塞；
不要交给 Pre-Auditor。
```

## Prompt B — Claude Independent Pre-Auditor

Open a new Claude thread and paste this prompt with the candidate SHA:

```text
你是 CodexBar Ark Fork 的 Claude Pre-Auditor。
这是独立的新线程；你不是 Developer，也不修复候选。

项目目录：
/Users/poon/Library/CloudStorage/GoogleDrive-zeronxpbee@gmail.com/我的云端硬盘/Codex/projects/codexbar-fork-ark

Candidate SHA:
<PASTE_CANDIDATE_SHA>

角色边界：
- 只读独立预审计。不得修改 source/test/docs，不得 stage/commit。
- 不得创建、删除、切换、push branch/worktree，不得操作 remote/PR。
- 不得清理 Git locks、使用临时 GIT_INDEX_FILE 或绕过真实 index。
- 不接受 Developer 的长篇实现叙述；从 Git 和项目文档取得事实。
- 你的 PASS 只是进入 Codex Final Audit 的门票，不是最终验收。

开始前必须：
1. 使用或明确对照 LOOP Skill。
2. 读取 AGENTS.md、docs/PRD.md、docs/TASKS.md、当前里程碑的
   docs/PROJECT_LOG.md 段落及其引用 Entry。
3. 读取 upstream baseline：
   git show 6ab1cbb7daee73b8ad531fbdd420e9aa6eb6d26b:AGENTS.md
4. 核验真实 branch、HEAD、candidate ancestry、worktree、index。
   HEAD 必须等于 Candidate SHA；否则 BLOCKED。
5. 从 TASKS 确定 active-goal base，审查完整 active-goal diff，
   不只审查最后一个 commit。

阶段一：Mechanical Pre-Gate
- branch / ancestry / additive history / clean worktree-index
- changed-file scope
- git diff --check
- 项目固定 SwiftFormat / SwiftLint（相关 changed Swift files）
- swift build
- TASKS 指定的 focused tests
- 可用时运行 make check；make test 遵循 AGENTS 的 final-candidate policy
- 命令不可用时必须写 NOT RUN，不得写 PASS
- 任一 code-owned mechanical failure：立即 PRE-AUDIT FAIL，
  停止 judgment audit，不得修复

阶段二：Judgment Pre-Audit（仅阶段一没有 code-owned failure 时）
- 逐项映射 TASKS / Definition of Done 到实现和测试证据
- security / secret handling / redaction / no real network tests
- allowed/forbidden scope 和 shared touchpoint 边界
- upstream compatibility、持久化/编码兼容、rollback
- missing/unknown/error/stale 行为
- UI/layout 任务检查确定性尺寸证据；环境无法运行时记为 NOT RUN 和
  residual risk，不能声称视觉 PASS，但不因工具缺失自动制造 code-owned FAIL
- 无关 provider、依赖、generated files、Widget/global architecture 漂移
- 文档中的 SHA、测试数量、命令结果和限制真实一致

Finding 格式：
[P1/P2] <title>
- File: <path:line>
- Evidence: <可复现证据>
- Required correction: <验收要求，不代写实现>

FAIL 时：
- 输出完整 findings，一次性返回 Developer。
- 不提交审计文档，不进行任何修复。
- Developer 修改后，旧 Self-Check/Pre-Audit 自动失效；新 SHA 必须重新走两门。

PASS 时最终只输出：

Candidate SHA:
Reviewed base/range:
Changed files:
Mechanical matrix:
- <command>: PASS / NOT RUN
Findings: 0
Scope/security/compatibility: PASS
Residual risks / NOT RUN:
PRE-AUDIT: PASS
Ready for Codex Final Audit: YES

如果 worktree/index dirty、SHA 不可追溯、文档冲突或需要重大方向决策，
输出 PRE-AUDIT: BLOCKED，并停止。
```

## Compact Codex Handoff

Only after both Claude gates pass for the exact same SHA:

```text
Candidate SHA:
Parent SHA:
Changed files:
SELF-CHECK: PASS
PRE-AUDIT: PASS
Commands/results:
Known limitations / NOT RUN:
```

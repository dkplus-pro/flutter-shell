# 证据目录

本目录存放各阶段的**真实执行证据**。没有证据的“通过”视为未完成。

## 命名

```text
p0-toolchain.md
p1-scaffold.md
p2-foundation.md
p3-bridge-android.md
p4-bridge-flutter.md
p5-data-abstractions.md
p6-ci-release.md
p7-ios-stub.md
p8-final.md
images/            # 截图，文件名含阶段与场景
```

## 每个文件至少包含

1. 日期与执行环境（Flutter/Dart/JDK/设备）；
2. 执行的完整命令；
3. 关键输出原文（版本、测试计数、`BUILD SUCCESSFUL`、`No issues found!`、APK 路径与体积、启动 TotalTime）；
4. 截图路径（UI/原生页）与 logcat 标记（`SCREEN_OPENED`、`RESULT ...`、`TICK_STOPPED`）；
5. 失败与修复记录（若发生）；
6. 结论：PASS / FAIL / 未验证。

## 规则

- 只写实测值，禁止估计或复制历史数字；
- 失败的证据也保留，不得删除后只留成功记录；
- 生成物一致性用 `git status --porcelain -- <生成路径>` 的输出作为证据；
- iOS 与远程 CI 只能记录为“未验证”，不得写成通过。

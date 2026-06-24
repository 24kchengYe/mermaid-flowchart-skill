---
name: mermaid-flowchart
description: 用 mermaid(mmdc)把项目/系统的流程、管线、状态机画成干净的流程图,渲染成 SVG(矢量)+ PNG(嵌入),配套柔和米灰主题与角色形状约定。当用户想画流程图/pipeline 图/架构流程/状态流转、把某段代码或项目的整体流程可视化、要 mermaid 转 svg/png、或问"流程图怎么画/渲染"时使用。不要手写 SVG 画流程图——会陷入和布局较劲。
---

# Mermaid 流程图(渲染成 SVG + PNG)

## 核心认知(先讲给用户)

流程 / 管线 / 状态机类图,**一律用 mermaid 写源码 + mmdc 渲染**,**不要手写 SVG**。手写 SVG 会陷进和坐标布局死磕、又挤又乱;mermaid 自动布局 + 角色形状 + GitHub 原生渲染源码,清晰且可改。

**两件产物**:`.mmd`(源,GitHub 直接渲染、可改)→ 渲染出 `.svg`(矢量,缩放不糊)+ `.png`(嵌入文档/PPT用)。

## 前置:只要有 Node 即可,零全局安装

`npx` 按需拉起 mmdc,不用 `npm install -g`。第一次会下载 puppeteer 的 Chromium(几十秒),之后有缓存。无 Node 就先装 Node ≥ 18。

## 渲染命令(本机验证可用)

> **懒人一键**:本 skill 附带 `render.sh`,`./render.sh flow.mmd` 直接出 `flow.svg`+`flow.png`(自动配好下面所有参数、支持超大图);`example.mmd` 是可直接渲的模板。手动命令见下。

先建一次性 puppeteer 配置(mmdc 底层用 headless Chrome,容器/公司机器常需 `--no-sandbox`):

```bash
echo '{"args":["--no-sandbox"]}' > /tmp/puppeteer.json
```

再渲染(同一份 .mmd 出两种格式):

```bash
# PNG(-s 4 = 4倍分辨率清晰;-b 浅底让亮/暗主题都可读)
npx -y @mermaid-js/mermaid-cli@latest -i flow.mmd -o flow.png -b "#FBFAF7" -p /tmp/puppeteer.json -s 4
# SVG(矢量,不需要 -s)
npx -y @mermaid-js/mermaid-cli@latest -i flow.mmd -o flow.svg -b "#FBFAF7" -p /tmp/puppeteer.json
```

## .mmd 模板(柔和米灰主题 + 角色形状)

直接拷这个开头,改节点和连线即可:

```
%%{init: {'theme':'base','themeVariables':{
  'fontFamily':'PingFang SC, Hiragino Sans GB, Helvetica, Arial, sans-serif',
  'fontSize':'15px',
  'primaryColor':'#FCFBF8','primaryBorderColor':'#D6D4CC','primaryTextColor':'#3A3A37',
  'lineColor':'#9A988F','tertiaryColor':'#FFFFFF'
}}}%%
flowchart TD
  IN(["输入 X<br/><small>来源说明</small>"])
  P1["处理步骤<br/><small>english</small>"]
  D1{"判定?<br/><small>条件</small>"}
  OUT(["输出 / 结束"])

  IN --> P1 --> D1
  D1 -->|是| OUT
  D1 -.->|"否 · 回退(虚线带标签)"| P1

  classDef router fill:#FBF3E2,stroke:#C99A3C,color:#8A5A12;
  classDef io fill:#F3F1EA,stroke:#CFCCC2,color:#3A3A37;
  classDef bad fill:#FBEEEA,stroke:#B5573A,color:#8A3A22;
  class D1 router;
  class IN,OUT io;
```

**角色形状约定**(一眼区分节点类型):

| 写法 | 形状 | 用途 |
|---|---|---|
| `(["..."])` | 圆角胶囊 | 输入 / 输出 / 起止 |
| `["..."]` | 矩形 | 过程 / 处理步骤 |
| `{"..."}` | 菱形 | 判定 / 分支 |
| `[("...")]` | 圆柱 | 数据存储 / 库 |

**配色克制**:整体米灰柔和;amber(`#C99A3C` 那套 `router` class)**只点关键判定/枢纽节点**;红(`bad`)只标失败/告警终点。中英双行用 `中文<br/><small>english</small>`。

## 内容原则:图只画流程,细节挪正文

图保持**干净**——只放节点和流转。状态标注、"已实现/待实现"、作用范围、计数、告警这些**全挪到正文 prose 或表格**,不要塞进图里。参考图之所以清爽,就是因为把细节 offload 了。

## 坑(踩过的,务必避开)

- **`linkStyle` 不接受 `color:` 属性** → 会 `Parse error`。只用 `stroke:` / `stroke-width:`。给边上色:`linkStyle 13 stroke:#4F8A5B,stroke-width:1.5px;`(编号从 0 起,按连线出现顺序数)。
- **虚线带标签用管道式** `A -.->|"标签<br/>第二行"| B`,**别用** `A -. "..." .-> B`(老语法易出错)。
- **节点文字含特殊字符**(`()`、`:`、`#`)时整体加引号:`["fix (n≤3)"]`。
- mmdc 报 Chromium 沙箱错 → 确认 `-p /tmp/puppeteer.json` 带上了 `--no-sandbox`。

## 落库约定(放进 md / 仓库)

1. 源存 `assets/<name>.mmd`,渲染出 `<name>.png`(文档里 `![](assets/x.png)` 嵌入)+ `<name>.svg`(矢量备用)。
2. md 里**再附一份 mermaid 源**放 `<details>` 折叠块,让 GitHub 网页直接渲染、同事可在线改:
   ````markdown
   <details><summary>流程图 mermaid 源</summary>

   ```mermaid
   %%{init: ...}%%
   flowchart TD
     ...
   ```
   </details>
   ````

## 画超大流程图(整个项目 / 多仓库 / 多文档)

**默认目标:一整张全景图。** 把整个项目的流程画在**一张图**里,才能"一眼看全、理解全局"——这正是画完整流程图的意义。**能放一张就别拆**:靠 `subgraph` 分模块 + 渲染放开上限,一张大图照样清晰。GitDiagram 那类工具产出的也是"单张 + 分组"图,不是一堆碎图。

### 关键:用 subgraph 把一张大图组织清楚

一整张图 ≠ 一团乱麻。把节点按**子系统 / 阶段**用 `subgraph` 圈成块,大图也层次分明:

```
flowchart TD
  subgraph ingest["① 接入层"]
    direction LR
    A[拉取] --> B[清洗]
  end
  subgraph core["② 核心处理"]
    C{判定} --> D[执行]
  end
  subgraph out["③ 输出"]
    E[落库] --> F[通知]
  end
  ingest --> core --> out
```
每个子系统一个 `subgraph`,模块间只连关键边 → 既是一整张、又分区清楚。`subgraph` 内可加 `direction LR` 单独控内部方向。

### 工作流(AI 按这个做)

1. **列 source 清单**:要覆盖的仓库 / 文档逐个列出(路径 + 一句话职责),确定全景范围,也方便人核对覆盖面。
2. **逐个抽流程**:读每个仓库 / 模块,理出它的节点和流转。
3. **合成一张全景图**:每个子系统包成一个 `subgraph`,子系统之间连主干边。节点 ID 带子系统前缀(`judge_table`、`fix_table`)避免重名、便于连跨模块的边。
4. **细节挪正文**:状态 / 计数 / 待办写在图周围,不塞进图(图只画流转)。
5. **标注待核对**:多仓库容易漏连线 / 脑补,产出标"⚠️ 待人核对",正确性人来把关。

### 大图渲染:放开 mmdc 上限

节点 / 边一多,mmdc 默认会报 `Maximum text size in diagram exceeded` 或 500 边上限。建 config 放开:
```bash
cat > /tmp/mmdc.json <<'JSON'
{ "maxTextSize": 9000000, "maxEdges": 5000,
  "flowchart": { "htmlLabels": true, "curve": "basis" } }
JSON
npx -y @mermaid-js/mermaid-cli@latest -i big.mmd -o big.svg -c /tmp/mmdc.json -p /tmp/puppeteer.json
```
- **优先出 svg**(矢量,大图放大不糊,浏览器里能缩放看局部);png 用 `-s 2`(别 `-s 4`,大图会爆内存 / 文件超大)。
- 宽系统用 `flowchart LR`(左右展开)比 `TD`(上下)更省纵向、更好读。
- mermaid 源也放进 md 的 `<details>`,GitHub 网页直接渲染、可在线缩放和改。

### 什么时候才拆成多张(例外,不是默认)

只有当一张图**真的大到 subgraph 也救不了**(几百节点、横竖都炸、svg 都看不清)才退而拆。拆时:
- 保留**一张顶层总览**(子系统当单节点,≤15 个)作为入口。
- 每个子系统单独一张子图,节点 ID 与总览保持一致。
- 用 `click 节点 "sub.md" "说明"` 交叉链接(GitHub/HTML 可点),`index.md` 串起来。

## 给"画整个项目流程"的同事(快速版)

目标是**一张全景图**:① 列出要覆盖的仓库 / 文档 → ② 每个子系统包成一个 `subgraph` → ③ 子系统之间连主干、合成一张图 → ④ 渲染放开上限、优先出 svg、mermaid 源附 `<details>`。**能一张就一张**;只有大到真看不清才退而拆多张 + 顶层总览。

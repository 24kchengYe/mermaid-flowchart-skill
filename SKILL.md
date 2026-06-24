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

## 画超大流程图(多仓库 / 多文档 / 整个系统)

单张图塞几百个节点 = 没法看,且 mmdc 会报 `maxTextSize`/`maxEdges` 错。超大系统的正解是 **拆 + 分层 + 索引 + 交叉链接**,不是硬画一张。

### 工作流(AI 按这个做)

1. **列 source 清单**:先把要覆盖的仓库 / 文档逐个列出(路径 + 一句话职责),别急着画。这就是"知识图谱"的目录,也方便人核对覆盖面。
2. **每个 source 抽一条主流程**:逐个仓库 / 模块画出它内部的流程(用基础模板),一个 source 一张子图。
3. **画一张顶层总览**:把每个子系统当成**单个节点**,只画**子系统之间**怎么连(谁触发谁、数据往哪流)。顶层只放 8–15 个节点,保持干净。
4. **建索引 + 交叉链接**:一个 `index.md`,顶层图在最上,下面列每张子图链接;顶层图节点用 `click` 跳到对应子图。
5. **标注待核对**:多仓库大系统里 AI 容易漏连线 / 脑补,产出时明确写"⚠️ 待人核对",图的正确性必须人 review。

### subgraph 分组(一张图里圈模块)

```
flowchart TD
  subgraph ingest["① 接入层"]
    direction LR
    A[拉取] --> B[清洗]
  end
  subgraph core["② 核心处理"]
    C{判定} --> D[执行]
  end
  ingest --> core
```
`subgraph ... end` 把相关节点框成一块,大图里一眼分区;子图内可加 `direction LR` 单独控方向。

### 节点 ID 跨图保持一致

同一个组件在不同图里**用同一个 id**(按子系统前缀:`judge_table`、`fix_table`),顶层图和子图才对得上、交叉链接才不乱。

### 交叉链接(点节点跳转)

```
click core "subsystems/core.md" "打开核心处理子图"
```
GitHub 渲染的 `<details>` mermaid 块和交互式 HTML 里可点跳转(静态 png/svg 点不了,但 GitHub 网页可以)→ **超大图务必把 mermaid 源放进 md,别只给图片**。

### 大图渲染:放开 mmdc 上限

节点 / 边一多,mmdc 会报 `Maximum text size in diagram exceeded` 或默认 500 边上限。建个 config 放开:
```bash
cat > /tmp/mmdc.json <<'JSON'
{ "maxTextSize": 9000000, "maxEdges": 5000,
  "flowchart": { "htmlLabels": true, "curve": "basis" } }
JSON
npx -y @mermaid-js/mermaid-cli@latest -i big.mmd -o big.svg -c /tmp/mmdc.json -p /tmp/puppeteer.json
```
- 宽系统用 `flowchart LR`(左右)比 `TD`(上下)更省纵向、更好读。
- 超大图**优先出 svg**(矢量,放大不糊);png 用 `-s 2`(别 `-s 4`,大图会爆内存 / 文件超大)。

### 铁律:拆,别硬画一张

- 一张图 > ~25 节点就该拆子图;顶层总览 ≤ 15 节点。
- 宁可 **5 张清楚的图 + 一个索引**,不要 1 张谁都看不懂的巨图。
- 细节(状态、计数、待办)写在图周围正文,不进图。

## 给"画整个项目流程"的同事(快速版)

懒得读全篇就记四步:① 列出要覆盖的仓库/文档清单 → ② 每个画一张子图(基础模板)→ ③ 画一张只连子系统的顶层总览 → ④ 建 `index.md` 串起来、png+svg 都出、mermaid 源附 `<details>`。复杂系统**一定拆多张**,别挤一张。

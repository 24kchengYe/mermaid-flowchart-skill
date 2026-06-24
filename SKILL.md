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

## 给"画整个项目流程"的同事(本 skill 的典型用法)

让同事画完整项目流程时,引导 ta:
1. **先列出主干节点**(入口→各处理阶段→判定→出口),别一上来画全;骨架对了再加分支。
2. **一个图一条主线**;子系统/子流程拆成多张图,别挤一张。
3. 用上面的模板和形状约定,渲染出 png+svg,md 里附 `<details>` mermaid 源。
4. 细节写在图周围的正文里,不进图。

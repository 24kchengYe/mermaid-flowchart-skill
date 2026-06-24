# mermaid-flowchart-skill

一个 [Claude Code](https://claude.com/claude-code) 技能 + 自包含教程:用 **mermaid(mmdc)** 把项目 / 系统的流程、管线、状态机画成**干净的流程图**,一键渲染成 **SVG(矢量)+ PNG(嵌入)**。

> 适合:画整个项目的完整流程、把复杂代码库的工作流可视化、给文档/PPT 配架构流程图。
> 不要手写 SVG 画流程图——会陷进和坐标布局死磕。

## 它固化了什么

- **柔和米灰主题模板**(直接拷开头改节点即可)
- **角色形状约定**:胶囊=输入输出 / 矩形=过程 / 菱形=判定 / 圆柱=存储
- **渲染命令**:`npx @mermaid-js/mermaid-cli` + puppeteer `--no-sandbox`,同一份 `.mmd` 出 png + svg
- **踩过的坑**:`linkStyle` 不接 `color` 属性、虚线带标签要用管道语法 `A -.->|"..."| B`
- **落库约定**:`.mmd` 源 + png 嵌入 + svg 矢量 + md 里附 `<details>` mermaid 源供 GitHub 在线渲染

## 怎么用

**A. 当 Claude Code 技能(推荐)**
```bash
mkdir -p ~/.claude/skills/mermaid-flowchart
curl -fsSL https://raw.githubusercontent.com/24kchengYe/mermaid-flowchart-skill/main/SKILL.md \
  -o ~/.claude/skills/mermaid-flowchart/SKILL.md
```
然后对 Claude 说一句"画个流程图"就会触发。

**B. 当普通教程**
直接看 [`SKILL.md`](./SKILL.md),命令、模板、坑全在里面,照着做即可。

## 一键脚本(最省事)

仓库带了 `render.sh` + `example.mmd`,clone 下来直接:
```bash
./render.sh example.mmd          # 出 example.svg + example.png
./render.sh 你的图.mmd 输出名      # 自动配好 puppeteer/mmdc,支持超大图
```

## 30 秒上手(手动)

```bash
echo '{"args":["--no-sandbox"]}' > /tmp/puppeteer.json
npx -y @mermaid-js/mermaid-cli@latest -i flow.mmd -o flow.png -b "#FBFAF7" -p /tmp/puppeteer.json -s 4
npx -y @mermaid-js/mermaid-cli@latest -i flow.mmd -o flow.svg -b "#FBFAF7" -p /tmp/puppeteer.json
```
`flow.mmd` 模板见 SKILL.md。

# SpectralML-Toolkit

用于光谱预处理、波长筛选、回归建模和结果诊断的 MATLAB 桌面工具箱。

[English](README.md) · [安装说明](docs/INSTALLATION.md) · [算法定义](docs/ALGORITHMS.md)

## 快速开始

1. 下载仓库并解压。
2. 打开 MATLAB，将“当前文件夹”切换到解压后的项目根目录。
3. 在命令行输入：

```matlab
startSpectralML
```

4. 点击 **Import data**，选择 `examples/example_spectra.csv`。
5. 第一次可选择 **Random → Raw → None → Ridge → Grid search**。
6. 点击右上角齿轮，在 **Parameters** 中将 **Grid values / parameter** 设为 `3`，点击 **OK**。
7. 点击 **Run analysis**。完成后点击 **Export results** 保存结果。

界面统一使用英文。**Cancel run** 用于请求取消当前运行；所有算法参数都在同一个可滚动窗口中，各方法的设置分别保存。

## 功能

| 模块 | 方法 |
| --- | --- |
| 样本划分 | Random、KS、SPXY |
| 预处理 | Raw、SG、SNV、MSC、FD、SD、FOD、Detrend、Min-Max、Z-score |
| 特征筛选 | None、CARS、VIP、UVE、SPA |
| 回归模型 | PLSR、PCR、Ridge、SVR、RF、XGBOOST、CNN |
| 参数寻优 | 网格搜索、随机搜索、贝叶斯优化 |
| 评价指标 | R²、RMSE、RPD、RPIQ、MAE、Bias |

## 数据格式

默认第一列是样本编号，第二列是目标值，第三列起为光谱。第一行的数值表头就是波长：

```text
SampleID,Target,350,355,360,...
Sample001,15.562,0.0411,0.0416,0.0413,...
```

支持CSV、XLSX和XLS。标准格式选择文件后自动导入；无法识别默认布局时打开列设置窗口。波长必须唯一且严格递增，ID不能重复，目标和光谱不能含缺失或非数值。示例数据是合成数据，不代表实测数据或模型精度。

## 环境

- 目标源码环境为 MATLAB R2023a/R2023b；跨版本兼容性尚未全面验证。
- PLSR、SVR、RF、特征筛选和贝叶斯优化需要 Statistics and Machine Learning Toolbox。
- CNN需要 Deep Learning Toolbox。
- 当前提供 MATLAB 源码，尚未包含独立Windows安装包。

## 结果与算法约定

六个图形页面包含原始光谱、样本分布、预处理光谱、特征波段、寻优过程和预测诊断。右侧表格按Train、CV、Test对照六项指标。图形仅导出300 dpi TIFF，同时导出CSV/XLSX、配置、搜索历史与MAT模型。

FOD的 **Fractional order (0–1)** 默认为0.5，采用Caputo L1定义。SVR核函数为Gaussian/Linear二选一，默认Gaussian。XGBOOST是本项目的MATLAB二阶正则化梯度树实现，与官方XGBoost库不保证数值等价。其他算法细节见英文算法文档。

预处理和筛选在每个交叉验证训练折内部拟合。CV同时用于选超参数，因此不是独立嵌套验证；SPXY使用目标值参与划分。残差定义为实测值减预测值。

## 测试状态

已提供自动化测试，但此修订版本尚未执行完整测试。全算法组合、跨版本及独立安装包验证仍待完成；项目不声称任何基准精度。

手动执行测试：

```matlab
addpath(genpath(pwd));
results = runtests('tests/test_spectralml.m');
table(results)
```

## 许可证

[MIT](LICENSE)。

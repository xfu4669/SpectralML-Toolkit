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


# SpectralML-Toolkit V1.0

**一款基于 MATLAB 开发的光谱数据预处理、特征筛选、回归建模与超参数优化可视化工具箱。**

SpectralML-Toolkit 是一款面向光谱数据分析与定量预测的开源 MATLAB 应用程序，为高光谱、近红外光谱（NIR）及其他光谱数据的科研分析提供集成化图形用户界面。

本工具箱集成了常用的光谱分析方法与机器学习算法，支持在统一界面中完成回归模型的构建、参数优化、性能评价及结果可视化，旨在简化光谱数据分析流程，提高科研建模效率。

## 主要功能

- **数据导入：** 支持导入光谱数据集，并自动识别波长信息。
- **样本划分：** 支持多种样本划分方法，可自定义训练集与测试集比例。
- **光谱预处理：** 集成常用光谱预处理与变换方法。
- **特征筛选：** 通过特征波段筛选算法提取有效光谱信息，降低数据维度。
- **回归建模：** 支持机器学习回归模型的构建与性能评价。
- **超参数优化：** 支持网格搜索（Grid Search）、随机搜索（Random Search）和贝叶斯优化（Bayesian Optimization）。
- **模型评价：** 提供 R²、RMSE、RPD、RPIQ、MAE 和 Bias 等评价指标。
- **结果可视化：** 支持光谱曲线、样本分布、特征波段、参数优化过程及模型预测结果的可视化展示。
- **结果导出：** 支持导出模型分析结果，便于后续科研分析与成果整理。

## 软件界面展示

### 1. 软件主界面

SpectralML-Toolkit 的图形用户界面，集成数据导入、样本划分、光谱预处理、特征筛选、回归建模及参数优化等主要功能。

![软件主界面](images/01_Main_Interface.png)

### 2. 原始光谱

展示导入数据集的原始光谱曲线及平均光谱，便于观察样本光谱的整体特征与变化趋势。

![原始光谱](images/03_Raw_spectra.png)

### 3. 样本分布

通过直方图与箱线图展示训练集和测试集的目标变量分布，辅助评价样本划分的合理性。

![样本分布](images/04_Sample_distribution.png)

### 4. 光谱预处理

展示光谱预处理后的反射率曲线，便于直观比较光谱变换效果及样本间的光谱差异。

![光谱预处理](images/05_Processed_spectra.png)

### 5. 特征波段筛选

在平均光谱曲线上标记筛选得到的特征波段，直观展示有效波长的分布情况。

![特征波段筛选](images/06_Selected_wavelengths.png)

### 6. 超参数优化

展示模型超参数搜索过程，包括各次参数评估结果及当前最优目标函数值，便于分析优化过程与模型性能变化。

![超参数优化](images/07_Optimization.png)

### 7. 模型精度评价

通过残差分布、残差散点图、实测值与预测值对比图及精度评价表，综合评价模型的预测性能。

![模型精度评价](images/08_Prediction_results.png)

### 8. 参数设置

提供统一的参数设置界面，支持交叉验证折数、优化目标、搜索次数、光谱预处理参数及模型参数的配置。

![参数设置](images/09_Parameters.png)

## 软件运行流程

1. 导入光谱数据及目标属性。
2. 选择样本划分方法，设置训练集与测试集比例。
3. 选择光谱预处理方法。
4. 设置特征波段筛选算法。
5. 选择机器学习回归模型。
6. 设置超参数优化方法。
7. 运行分析，完成模型训练与参数寻优。
8. 查看模型评价结果并导出分析数据。

## 开发信息

- **开发语言：** MATLAB
- **软件版本：** V1.0
- **软件界面：** MATLAB 图形用户界面（GUI）
- **应用领域：** 高光谱分析、近红外光谱分析、土壤属性定量反演及光谱定量建模。

## 快速开始

下载或克隆本项目仓库，在 MATLAB 环境中打开项目文件，并运行主程序入口，即可启动 SpectralML-Toolkit。

`examples` 文件夹提供示例数据，可用于熟悉软件的基本操作流程。

部分算法可能依赖 MATLAB 附加工具箱，请根据源代码及本地 MATLAB 环境检查相关依赖。

## 交流与贡献

欢迎对本项目提出改进建议、反馈程序问题或参与代码完善。

可通过 GitHub Issues 提交问题，也欢迎通过 Pull Requests 参与项目开发。

希望本项目能够为光谱分析、机器学习建模及相关科研工作的学习与交流提供参考。

## 开源许可证

本项目采用 MIT License 开源许可证，具体许可条款请参阅仓库中的 LICENSE 文件。

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

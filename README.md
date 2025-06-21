[English](#english-guide) | [中文](#chinese-guide)

![chawrt logo](include/logo.png)

chawrt is a variant of the OpenWrt project, focused on providing a custom firmware experience. This guide outlines how to compile chawrt firmware from source.

## Building chawrt Firmware

To build your own chawrt firmware you need a GNU/Linux, BSD or macOS system (case
sensitive filesystem required). Cygwin is unsupported because of the lack of a
case sensitive file system.

### Related Repositories

chawrt uses the following main repositories for its LuCI interface and packages:

* [LuCI Web Interface](https://github.com/liudf0716/luci): Modern and modular
  interface to control the device via a web browser.

* [chawrt Packages](https://github.com/liudf0716/packages): Main package repository for chawrt.

## License

chawrt is licensed under GPL-2.0


<a name="english-guide"></a>
## Compiling ChaWrt on Ubuntu 24.04 (English)

This guide provides step-by-step instructions for compiling ChaWrt firmware on an Ubuntu 24.04 system.

### 1. System Requirements

*   **CPU**: A modern multi-core processor (e.g., Intel Core i5/i7/i9, AMD Ryzen 5/7/9) is recommended for faster compilation.
*   **RAM**: At least 4GB of RAM is required, but 8GB or more is highly recommended, especially for parallel builds.
*   **Disk Space**: A minimum of 25GB of free disk space is needed. 50GB or more is recommended to accommodate sources, toolchains, and build outputs for multiple targets. Ensure your build directory is on a case-sensitive filesystem.
*   **Internet Connection**: A stable internet connection is required to download source code and packages.

### 2. Install Prerequisites

Open a terminal and run the following commands to update your system and install the necessary packages:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential clang flex bison g++ gawk gcc-multilib gettext git libncurses-dev libssl-dev rsync unzip zlib1g-dev file wget
```

### 3. Clone ChaWrt Repository

If you haven't already, clone the ChaWrt repository:

```bash
git clone https://github.com/liudf0716/chawrt.git chawrt
cd chawrt
```
*(Note: Replace `https://github.com/liudf0716/chawrt.git` with the actual URL of the ChaWrt Git repository if it's different, e.g., your own fork.)*

### 4. Update and Install Feeds

Update and install the package feeds:

```bash
./scripts/feeds update -a
./scripts/feeds install -a
```

### 5. Configure Your Build

Use `menuconfig` to select your target device, desired packages, and other firmware options:

```bash
make menuconfig
```
Navigate the menus using the arrow keys. Select options with the spacebar. Use 'y' to include, 'm' to build as a module (if applicable), and 'n' to exclude. Save your configuration when exiting.

*   **Target System**: Select the appropriate SoC family for your device.
*   **Target Profile**: Select the specific model of your device.
*   **LuCI -> Applications**: Select LuCI applications you want to include.
*   **LuCI -> Themes**: Select LuCI themes.

### 6. Compile the Firmware

Start the compilation process. Using the `-j` option allows for parallel jobs, significantly speeding up the build. `$(nproc)` automatically uses the number of available processor cores.

```bash
make -j$(nproc)
```

The first build will take a significant amount of time as it downloads all source code and builds the toolchain from scratch. Subsequent builds will be faster.

### 7. Firmware Output

Once the build is complete, the firmware images will be located in the `bin/targets/<target_system>/<subtarget>/` directory (e.g., `bin/targets/ramips/mt7621/`). Look for files with names like `...-squashfs-sysupgrade.bin` or `...-initramfs-kernel.bin` depending on your device and needs.

### 8. Troubleshooting

*   **Build errors**: Carefully read the error messages. Often, they indicate missing dependencies or configuration issues.
*   **Insufficient disk space**: Ensure you have enough free space as specified in the requirements.
*   **Case-sensitive filesystem**: Building on a case-insensitive filesystem (like default macOS or Windows NTFS) will lead to errors.
*   **Consult the community**: If you encounter issues, search online forums or the ChaWrt community channels for help. Provide detailed logs and information about your setup.

```


<a name="chinese-guide"></a>
## 在 Ubuntu 24.04 上编译 ChaWrt (中文)

本指南提供在 Ubuntu 24.04 系统上编译 ChaWrt 固件的详细步骤。

### 1. 系统需求

*   **CPU (处理器)**: 推荐使用现代多核处理器（例如 Intel Core i5/i7/i9, AMD Ryzen 5/7/9）以加快编译速度。
*   **RAM (内存)**: 至少需要 4GB 内存，但强烈推荐 8GB 或更多，尤其是在进行并行编译时。
*   **Disk Space (磁盘空间)**: 至少需要 25GB 可用磁盘空间。推荐 50GB 或更多，以容纳多个目标的源代码、工具链和编译输出。请确保您的编译目录位于区分大小写的文件系统上。
*   **Internet Connection (网络连接)**: 需要稳定的网络连接以下载源代码和软件包。

### 2. 安装编译依赖

打开终端并运行以下命令来更新您的系统并安装必要的软件包：

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential clang flex bison g++ gawk gcc-multilib gettext git libncurses-dev libssl-dev rsync unzip zlib1g-dev file wget
```

### 3. 克隆 ChaWrt 仓库

如果您尚未克隆 ChaWrt 仓库，请执行以下操作：

```bash
git clone https://github.com/liudf0716/chawrt.git chawrt
cd chawrt
```
*(注意: 请将 `https://github.com/liudf0716/chawrt.git` 替换为实际的 ChaWrt Git 仓库 URL，例如您自己的 fork。)*

### 4. 更新并安装 Feeds

更新并安装软件包源 (feeds):

```bash
./scripts/feeds update -a
./scripts/feeds install -a
```

### 5. 配置您的编译选项

使用 `menuconfig` 来选择您的目标设备、期望的软件包以及其他固件选项：

```bash
make menuconfig
```
使用方向键在菜单中导航。使用空格键选择选项。使用 'y' 包含，'m' 编译为模块 (如果适用)，'n' 排除。退出时保存您的配置。

*   **Target System (目标系统)**: 为您的设备选择合适的 SoC 系列。
*   **Target Profile (目标配置文件)**: 选择您设备的具体型号。
*   **LuCI -> Applications (LuCI 应用)**: 选择您想要包含的 LuCI 应用程序。
*   **LuCI -> Themes (LuCI 主题)**: 选择 LuCI 主题。

### 6. 编译固件

开始编译过程。使用 `-j` 选项允许多线程并行编译，从而显著加快编译速度。`$(nproc)` 会自动使用可用的处理器核心数量。

```bash
make -j$(nproc)
```

第一次编译会花费较长时间，因为它需要下载所有源代码并从头构建工具链。后续的编译会更快。

### 7. 固件输出

编译完成后，固件镜像将位于 `bin/targets/<target_system>/<subtarget>/` 目录中 (例如, `bin/targets/ramips/mt7621/`)。根据您的设备和需求，查找名为 `...-squashfs-sysupgrade.bin` 或 `...-initramfs-kernel.bin` 之类的文件。

### 8. 问题排查

*   **编译错误 (Build errors)**: 仔细阅读错误信息。通常，它们会指出缺少的依赖项或配置问题。
*   **磁盘空间不足 (Insufficient disk space)**: 确保您有足够的可用空间，如需求中所述。
*   **区分大小写的文件系统 (Case-sensitive filesystem)**: 在不区分大小写的文件系统（如默认的 macOS 或 Windows NTFS）上编译会导致错误。
*   **咨询社区 (Consult the community)**: 如果遇到问题，请在线搜索论坛或 ChaWrt 社区寻求帮助。提供详细的日志和有关您的设置的信息。

```

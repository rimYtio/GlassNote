# GlassNote

A local-first, elegant note-taking app with timeline management, voice capture, AI-powered transcription, and liquid glass UI design. Built with Flutter.

---

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [License](#license)

---

## Features

**Notes & Organization**
- Create, edit, and delete rich text notes with flutter_quill editor
- Organize notes into custom folders with custom colors
- Tag notes for flexible categorization and filtering

**Voice Capture & AI Transcription**
- Record audio directly in-app with the built-in voice recorder
- Transcribe recordings to text via Volcengine streaming ASR (real-time speech recognition)
- Generate structured note content from raw captions using AI providers: DeepSeek, OpenAI, or SiliconFlow

**Timeline & Task Management**
- Schedule tasks on an interactive timeline view
- Set reminders with local push notifications
- Manage deadlines and track progress visually

**Security & Privacy**
- App lock with biometric authentication (fingerprint / face)
- All data stored locally using SQLite via Drift (no cloud sync by default)
- Credentials stored in FlutterSecureStorage

**Rich Editing & Export**
- Full rich text editing: headings, lists, formatting, inline styles
- Attach images to notes via the image picker
- Export notes as PDF or PNG images
- Share notes via platform share sheet

**UI & Experience**
- Liquid glass visual theme with frosted blur effects
- Smooth page transitions and animated interactions

---

## Tech Stack

| Category | Libraries |
|---|---|
| Framework | Flutter (Dart 3.12+) |
| State Management | Riverpod |
| Navigation | GoRouter |
| Database | Drift (SQLite) |
| Rich Text | flutter_quill |
| Audio Recording | record, audioplayers |
| AI Providers | Volcengine ASR, DeepSeek, OpenAI, SiliconFlow |
| Security | flutter_secure_storage, local_auth |
| Notifications | flutter_local_notifications |
| Export | pdf, share_plus |
| Image Picking | image_picker |
| Animations | rive, lottie |

---

## Architecture

The project follows **Clean Architecture** with four layers:

```
lib/
├── domain/           # Entities, repository interfaces, domain services
├── application/      # Use cases and application-level state (Riverpod providers)
├── infrastructure/   # Concrete implementations: database (Drift), AI clients, audio, security, notifications, export, file system
└── presentation/     # Flutter UI: pages, widgets, themes (organized under features/)
```

Data flows inward: presentation depends on application, application depends on domain, and infrastructure implements domain interfaces via dependency injection.

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.12+)
- Android SDK / Xcode (for iOS builds)
- A device or emulator running Android 5.0+ or iOS 13+

### Setup

```bash
# Clone the repository
git clone <repo-url>
cd GlassNote

# Install dependencies
flutter pub get

# Generate Drift database code
dart run build_runner build

# Run on a connected device
flutter run
```

### AI Configuration

To enable AI transcription features, configure your API keys in the app settings:

1. Open the app and navigate to **Settings > AI Settings**
2. Enter your API keys for the providers you want to use:
   - **Volcengine ASR** (for speech-to-text transcription)
   - **DeepSeek**, **OpenAI**, or **SiliconFlow** (for caption-to-note conversion)
3. Keys are stored securely in the device keychain via FlutterSecureStorage

---

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── app/
│   ├── app.dart                       # MaterialApp.router configuration
│   ├── app_shell.dart                 # Bottom navigation shell
│   ├── bootstrap.dart                 # Initialization logic
│   ├── di/                            # Dependency injection
│   ├── lifecycle/                     # App lifecycle handlers
│   ├── router.dart                    # GoRouter route definitions
│   └── theme/                         # Light/dark themes
├── core/
│   ├── errors/                        # Error handling
│   └── logging/                       # Logging utilities
├── domain/
│   ├── entities/                      # Note, Folder, Tag, TimelineTask, etc.
│   ├── repositories/                  # Repository interfaces
│   └── services/                      # Domain services
├── application/                       # Riverpod providers (per feature)
│   ├── capture/
│   ├── folders/
│   ├── notes/
│   ├── settings/
│   └── timeline/
├── infrastructure/
│   ├── ai/                            # AI provider clients (ASR, LLM)
│   ├── audio/                         # Audio recording/playback
│   ├── database/                      # Drift database & DAOs
│   ├── export/                        # PDF/PNG export
│   ├── file_system/                   # File I/O
│   ├── notifications/                 # Local push notifications
│   ├── providers/                     # Infrastructure-level providers
│   ├── repositories/                  # Repository implementations
│   └── security/                      # Biometric auth, secure storage
├── features/                          # UI pages (per feature)
│   ├── capture/                       # Quick capture page
│   ├── folders/                       # Folder management
│   ├── home/                          # Home overview
│   ├── notes/                         # Note list & rich editor
│   ├── schedule/                      # Timeline view
│   ├── settings/                      # Settings & sub-pages
│   ├── splash/                        # Splash screen
│   ├── trash/                         # Trash / recycle bin
│   └── voice/                         # Voice recording interface
└── ui_system/                         # Shared UI components
    ├── animations/
    └── widgets/
```

---

## License

MIT License. See [LICENSE](LICENSE) for details.

---

---

# GlassNote (中文)

一个本地优先的优雅笔记应用，支持时间线管理、语音录制、AI 智能转录，采用液态玻璃风格 UI 设计。基于 Flutter 构建。

---

## 目录

- [功能特性](#功能特性)
- [技术栈](#技术栈)
- [架构说明](#架构说明)
- [快速开始](#快速开始)
- [项目结构](#项目结构)
- [许可证](#许可证)

---

## 功能特性

**笔记与整理**
- 使用 flutter_quill 富文本编辑器创建、编辑和删除笔记
- 自定义文件夹（支持自定义颜色）组织笔记
- 标签系统，支持灵活分类与筛选

**语音录制与 AI 转录**
- 内置录音功能，直接录制音频
- 通过火山引擎流式 ASR 实时将语音转为文字
- 利用 DeepSeek、OpenAI 或 SiliconFlow 等 AI 服务，将原始转录内容转换为结构化笔记

**时间线与任务管理**
- 在交互式时间线视图上安排任务
- 设置提醒并通过本地推送通知接收
- 可视化追踪截止日期和进度

**安全与隐私**
- 应用锁，支持生物识别（指纹 / 面容）
- 所有数据通过 Drift（SQLite）本地存储，默认无云同步
- 敏感凭据存储于 FlutterSecureStorage（系统钥匙串）

**富文本编辑与导出**
- 完整富文本编辑：标题、列表、格式化、内联样式
- 通过图片选择器为笔记添加图片附件
- 支持将笔记导出为 PDF 或 PNG 图片
- 通过系统分享面板分享笔记

**界面体验**
- 液态玻璃视觉主题，毛玻璃模糊效果
- 流畅的页面过渡与交互动画

---

## 技术栈

| 类别 | 技术 |
|---|---|
| 框架 | Flutter (Dart 3.12+) |
| 状态管理 | Riverpod |
| 导航路由 | GoRouter |
| 数据库 | Drift (SQLite) |
| 富文本 | flutter_quill |
| 音频录制 | record, audioplayers |
| AI 服务 | 火山引擎 ASR、DeepSeek、OpenAI、SiliconFlow |
| 安全 | flutter_secure_storage、local_auth |
| 通知 | flutter_local_notifications |
| 导出 | pdf、share_plus |
| 图片选择 | image_picker |
| 动画 | rive、lottie |

---

## 架构说明

项目遵循 **Clean Architecture**（整洁架构），分为四层：

```
lib/
├── domain/           # 实体、仓储接口、领域服务
├── application/      # 用例与应用程序级状态（Riverpod providers）
├── infrastructure/   # 具体实现：数据库（Drift）、AI 客户端、音频、安全、通知、导出、文件系统
└── presentation/     # Flutter UI：页面、组件、主题（按 features/ 组织）
```

数据流方向向内：展示层依赖应用层，应用层依赖领域层，基础设施层通过依赖注入实现领域接口。

---

## 快速开始

### 环境要求

- [Flutter SDK](https://docs.flutter.dev/get-started/install)（3.12 及以上）
- Android SDK 或 Xcode（用于 iOS 构建）
- Android 5.0+ 或 iOS 13+ 的设备或模拟器

### 安装与运行

```bash
# 克隆仓库
git clone <repo-url>
cd GlassNote

# 安装依赖
flutter pub get

# 生成 Drift 数据库代码
dart run build_runner build

# 连接设备后运行
flutter run
```

### AI 功能配置

使用 AI 转录功能前，需在应用内配置 API 密钥：

1. 打开应用，进入 **设置 > AI 设置**
2. 输入对应服务商的 API 密钥：
   - **火山引擎 ASR**（语音转文字）
   - **DeepSeek**、**OpenAI** 或 **SiliconFlow**（转录内容转笔记）
3. 密钥通过 FlutterSecureStorage 安全存储在系统钥匙串中

---

## 项目结构

```
lib/
├── main.dart                          # 应用入口
├── app/
│   ├── app.dart                       # MaterialApp.router 配置
│   ├── app_shell.dart                 # 底部导航栏
│   ├── bootstrap.dart                 # 初始化逻辑
│   ├── di/                            # 依赖注入
│   ├── lifecycle/                     # 应用生命周期处理
│   ├── router.dart                    # GoRouter 路由定义
│   └── theme/                         # 亮色/暗色主题
├── core/
│   ├── errors/                        # 错误处理
│   └── logging/                       # 日志工具
├── domain/
│   ├── entities/                      # Note、Folder、Tag、TimelineTask 等实体
│   ├── repositories/                  # 仓储接口
│   └── services/                      # 领域服务
├── application/                       # Riverpod providers（按功能模块）
│   ├── capture/
│   ├── folders/
│   ├── notes/
│   ├── settings/
│   └── timeline/
├── infrastructure/
│   ├── ai/                            # AI 供应商客户端（ASR、LLM）
│   ├── audio/                         # 音频录制/播放
│   ├── database/                      # Drift 数据库与 DAO
│   ├── export/                        # PDF/PNG 导出
│   ├── file_system/                   # 文件 I/O
│   ├── notifications/                 # 本地推送通知
│   ├── providers/                     # 基础设施级 providers
│   ├── repositories/                  # 仓储实现
│   └── security/                      # 生物识别认证、安全存储
├── features/                          # UI 页面（按功能模块）
│   ├── capture/                       # 快速记录页面
│   ├── folders/                       # 文件夹管理
│   ├── home/                          # 首页概览
│   ├── notes/                         # 笔记列表与富文本编辑器
│   ├── schedule/                      # 时间线视图
│   ├── settings/                      # 设置及其子页面
│   ├── splash/                        # 启动页
│   ├── trash/                         # 回收站
│   └── voice/                         # 语音录制界面
└── ui_system/                         # 共享 UI 组件
    ├── animations/
    └── widgets/
```

---

## 许可证

MIT License。详见 [LICENSE](LICENSE) 文件。

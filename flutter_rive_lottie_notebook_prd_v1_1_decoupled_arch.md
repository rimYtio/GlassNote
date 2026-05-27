# 基于 Flutter + Rive + Lottie 的本地笔记本 App 完整需求文档

> 文档版本：v1.1  
> 项目定位：本地优先、强视觉交互、支持 AI 配置的个人笔记与行程管理 App  
> 推荐技术栈：Flutter + Rive + Lottie + 本地数据库 + 本地加密 + 可配置 AI API  
> 适用对象：产品设计、Flutter 开发、Agent 自动开发、后续架构重构

---

## 1. 项目概述

本项目是一款面向个人使用的本地化笔记本软件，核心目标是提供高质量的笔记记录、文件夹管理、时间线行程管理、语音随记、图片与音频附件、本地加密、PDF/PNG 导出以及可配置 AI API 能力。产品不以账号体系和跨设备同步作为首期目标，而是优先完成稳定、本地、可控、视觉体验突出的单机版应用。

与普通笔记软件相比，本项目强调三个方向：第一，笔记与行程管理结合，用户既可以沉淀内容，也可以通过时间线管理任务、计划和提醒；第二，界面需要具有较强的动画和交互表现力，使用 Flutter 保证跨平台 UI 一致性，使用 Rive 实现强交互状态动画，使用 Lottie 实现轻量级状态动效；第三，预留 AI 能力入口，用户可在设置中自行配置 OpenAI、硅基流动、DeepSeek 或其他兼容 API 的服务，用于语音转写、笔记润色、摘要生成、待办提取等功能。

本项目首期采用本地优先架构，不引入账号登录、云同步和多人协作。所有核心数据默认保存在本地，并通过数据库加密、文件加密或应用级加密机制保护用户隐私。

---

## 2. 产品目标

### 2.1 核心目标

本产品的核心目标是构建一款高完成度的个人笔记与行程管理工具。它不仅需要具备常规笔记软件的文本记录能力，还需要支持富文本编辑、图片和音频附件、笔记分类、快速搜索、时间线行程、语音输入、导出与本地加密。界面层面需要具有明显的视觉品质，重点体现页面转场、微交互、语音按钮动画、时间线节点动画、空状态动画和操作反馈动画。

### 2.2 设计目标

产品设计应遵循“本地优先、轻量闭环、强交互反馈、可扩展 AI”的原则。所有基础功能必须在无网络环境下可使用；AI 功能可以依赖用户配置的 API，但不能影响笔记、行程、附件和提醒等本地核心能力。视觉上应避免传统工具软件的僵硬感，采用卡片式布局、流畅过渡、细腻阴影、柔和色彩、可控动效和低干扰交互。

### 2.3 技术目标

技术上应建立清晰的 Flutter 分层架构，使 UI、业务逻辑、数据访问、本地文件、加密、安全配置和 AI 服务解耦。项目应允许后续扩展云同步、账号体系、插件市场、主题系统、Server-Driven UI 或桌面端适配，但首期不实现这些复杂能力。

---

## 3. 用户画像与使用场景

### 3.1 目标用户

首期目标用户为个人自用场景，用户具备一定技术能力，能够在设置界面中配置 API Key、选择模型服务商，并接受本地数据管理模式。用户主要使用手机进行随手记录、行程规划、灵感捕捉、语音速记和资料整理。

### 3.2 典型场景

用户在日常学习、工作或出行过程中，需要快速记录想法，可以通过首页的悬浮话筒按钮进行语音随记。系统将语音保存为音频附件，并可在用户配置 AI API 后自动转写为文本。用户也可以在笔记编辑器中插入图片、音频、待办项和标题段落，并将笔记归入不同文件夹。对于有时间属性的事项，用户可以创建时间线行程，设置提醒，并在首页或行程页以时间轴方式查看。

当用户需要整理内容时，可以对笔记进行搜索、分类、导出 PDF 或 PNG 图片。由于产品首期为本地单机版，所有数据应默认存储在设备本地，不依赖服务器。

---

## 4. 产品范围

### 4.1 首期必须实现

首期必须实现完整的本地笔记闭环，包括文件夹分类、富文本笔记创建与编辑、笔记保存、图片附件、音频附件、时间线行程、提醒、语音随记入口、基础搜索、PDF 导出、PNG 导出、本地加密、AI API 配置页面和基础视觉动效。

### 4.2 首期不实现

首期不实现账号注册、云同步、多人协作、Web 端、桌面端、插件市场、团队空间、付费系统、公开分享链接和复杂权限体系。上述功能可以作为后续版本扩展，但不应影响首期架构设计。

### 4.3 后续可扩展

后续可以增加账号体系、WebDAV/iCloud/Google Drive 同步、端到端加密同步、模板市场、主题商店、OCR、Markdown 导入导出、AI Agent 工作流、日历集成、桌面端适配以及局部 Server-Driven UI。

---

## 5. 技术选型总览

### 5.1 主框架

项目主框架采用 Flutter。Flutter 用于实现 Android 和 iOS 的统一 UI、路由、动画、页面布局和业务交互。所有核心页面应优先使用 Flutter Widget 原生实现，而不是大量依赖 WebView。WebView 只在富文本编辑器或特定复杂内容编辑场景下作为可选方案使用。

### 5.2 动画体系

Rive 用于强交互动画，包括语音按钮状态机、录音波形、首页引导动画、时间线节点展开、AI 思考状态和重点按钮反馈。Lottie 用于非交互状态动画，包括加载中、导出成功、空状态、提醒完成、错误提示和页面插画。Flutter 自带动画体系用于页面转场、卡片展开、Hero 动画、列表重排、主题切换和微交互。

### 5.3 状态管理

推荐使用 Riverpod 作为状态管理框架。Riverpod 适合中大型 Flutter 项目，便于将 UI 状态、业务状态、异步任务、数据库访问和配置管理解耦。如果开发团队更熟悉 Bloc，也可以使用 Bloc，但整个项目应保持统一，不允许同一层级混用多种状态管理风格。

### 5.4 路由管理

推荐使用 go_router 管理路由。路由需要支持首页、笔记列表、笔记详情、编辑器、文件夹、行程时间线、行程详情、语音记录、设置、AI 配置、安全设置、导出预览等页面。路由应具备清晰命名，方便后续深链接和通知跳转扩展。

### 5.5 本地数据库

本地数据库推荐使用 Drift 或 Isar。若重视关系型数据、复杂查询、迁移和 SQL 可控性，优先选择 Drift；若重视对象存储和较高性能，可以选择 Isar。由于本项目涉及笔记、文件夹、附件、行程、提醒、设置、标签等多表关系，推荐优先使用 Drift + SQLite。

### 5.6 本地加密

本地加密包括数据库加密、附件文件加密和敏感配置加密。AI API Key 不应以明文形式存储。可使用安全存储机制保存密钥，再使用应用层加密保护数据库或敏感字段。对于附件，可采用文件级加密或私有目录隔离加密策略。

### 5.7 富文本编辑器

首期可采用 Flutter 原生富文本编辑器方案，也可以采用 Flutter + WebView 嵌入 Web 富文本编辑器方案。若重点是稳定、快速实现，可优先使用现有 Flutter 富文本编辑器；若后续需要复杂块编辑能力、类似 Notion 的块结构、嵌入多媒体、拖拽和高级排版，则建议采用 WebView 嵌入 Tiptap / ProseMirror / Lexical 类型编辑器。

### 5.8 AI 能力

AI 能力通过用户自行配置 API 实现。系统不内置固定服务商账户。设置界面应允许用户配置 API Base URL、API Key、模型名称、语音模型、文本模型、温度参数、请求超时和代理选项。AI 功能应作为增强能力存在，不能影响本地核心功能。

---

## 6. 总体架构设计

### 6.1 架构目标

本项目必须采用“UI 表现层与核心功能层分离”的架构。UI 层可以频繁重构、替换动效、调整布局和升级视觉系统，但不得影响笔记保存、文件管理、数据库、加密、提醒、导出、附件和 AI 配置等核心能力。项目不允许出现页面 Widget 直接访问数据库、直接读写文件、直接调用加密模块或直接拼接 AI 请求的写法。

本项目的架构目标不是简单地把代码按文件夹分类，而是建立稳定的依赖边界：上层可以依赖下层抽象，下层不得反向依赖 UI。这样后期即使将 Flutter 页面从普通 Widget 改为更复杂的 Rive 交互界面，或者引入局部 Server-Driven UI，也不需要重写核心业务逻辑。

### 6.2 推荐架构风格

项目推荐采用 Clean Architecture + Feature Modularization 的组合。整体划分为四个主要层级：Presentation、Application、Domain 和 Infrastructure/Data。

```text
Presentation 层：页面、组件、主题、动画、路由、交互状态
        ↓
Application 层：用例编排、状态控制、表单校验、异步任务调度
        ↓
Domain 层：核心实体、值对象、业务规则、仓库接口
        ↑
Infrastructure/Data 层：数据库、文件、加密、通知、AI API、导出实现
```

严格依赖规则如下：

```text
允许：presentation -> application -> domain
允许：data/infrastructure -> domain interface
禁止：domain -> presentation
禁止：domain -> Flutter / BuildContext / Widget
禁止：application -> Widget / BuildContext
禁止：presentation -> Drift / SQLite / File / Crypto / HTTP 具体实现
```

### 6.3 分层职责

| 层级 | 职责 | 可以包含 | 不允许包含 |
|---|---|---|---|
| Presentation | UI 展示、页面交互、动画、主题、路由 | Widget、Page、ViewModel、Controller、Rive/Lottie 控制 | 数据库 SQL、文件读写、加密实现、HTTP 请求细节 |
| Application | 用例编排和状态协调 | SaveNoteUseCase、CreateReminderUseCase、ExportNoteUseCase、Provider/Notifier | 具体 UI 布局、BuildContext、动画资源 |
| Domain | 稳定业务模型和规则 | Note、Folder、ScheduleEvent、Attachment、Repository 抽象、业务校验 | Flutter 包、数据库包、网络包、插件包 |
| Infrastructure/Data | 外部能力适配 | Drift、SQLite、FileStorage、CryptoService、NotificationService、AIClient、Exporter | 页面逻辑、视觉状态、动画状态机 |

### 6.4 推荐目录结构

```text
lib/
  main.dart

  app/
    bootstrap.dart                 # 应用启动、依赖注入、初始化
    app.dart                       # MaterialApp / CupertinoApp 外壳
    router.dart                    # go_router 路由
    theme/
      app_theme.dart
      app_colors.dart
      app_typography.dart
    lifecycle/
      app_lifecycle_observer.dart

  ui_system/                       # 可替换的视觉系统，不承载核心业务
    widgets/
      app_button.dart
      app_card.dart
      app_text_field.dart
      empty_state.dart
    animations/
      rive_controller_adapter.dart
      lottie_asset.dart
      motion_tokens.dart
    layout/
      spacing.dart
      breakpoints.dart
    themes/
      theme_tokens.dart

  core/
    errors/
      failure.dart
      exception_mapper.dart
    utils/
      result.dart
      date_time_utils.dart
    permissions/
      permission_gateway.dart
    logging/
      app_logger.dart

  domain/                          # 与 Flutter 无关的纯业务核心
    entities/
      note.dart
      folder.dart
      attachment.dart
      schedule_event.dart
      reminder.dart
      ai_provider_config.dart
    value_objects/
      note_id.dart
      folder_id.dart
      encrypted_text.dart
      attachment_path.dart
    repositories/
      note_repository.dart
      folder_repository.dart
      attachment_repository.dart
      schedule_repository.dart
      settings_repository.dart
    services/
      encryption_policy.dart
      export_policy.dart
      reminder_policy.dart
    rules/
      note_validation_rule.dart
      schedule_validation_rule.dart

  application/                     # 用例层，负责把核心能力组织成 App 行为
    notes/
      create_note_use_case.dart
      update_note_use_case.dart
      delete_note_use_case.dart
      search_notes_use_case.dart
      export_note_use_case.dart
    folders/
      create_folder_use_case.dart
      move_note_to_folder_use_case.dart
    schedule/
      create_schedule_event_use_case.dart
      update_schedule_event_use_case.dart
      schedule_reminder_use_case.dart
    voice/
      save_voice_record_use_case.dart
      transcribe_voice_use_case.dart
    ai/
      save_ai_config_use_case.dart
      summarize_note_use_case.dart
      polish_note_use_case.dart
    settings/
      update_app_settings_use_case.dart

  infrastructure/                  # 插件、系统、外部服务适配
    database/
      app_database.dart
      tables/
      daos/
      migrations/
    repositories/
      note_repository_impl.dart
      folder_repository_impl.dart
      attachment_repository_impl.dart
      schedule_repository_impl.dart
      settings_repository_impl.dart
    file_system/
      app_file_store.dart
      attachment_file_store.dart
      export_file_store.dart
    crypto/
      key_store.dart
      database_encryptor.dart
      file_encryptor.dart
      api_key_encryptor.dart
    notifications/
      local_notification_service.dart
    ai_clients/
      ai_client.dart
      openai_compatible_client.dart
    export/
      pdf_exporter.dart
      png_exporter.dart
    speech/
      recorder_service.dart
      audio_file_service.dart

  features/                        # 具体功能的 UI 与状态适配
    home/
      presentation/
        home_page.dart
        home_controller.dart
        widgets/
    notes/
      presentation/
        note_list_page.dart
        note_editor_page.dart
        note_editor_controller.dart
        note_view_model.dart
        widgets/
    folders/
      presentation/
        folder_page.dart
        folder_controller.dart
    schedule/
      presentation/
        schedule_timeline_page.dart
        schedule_editor_page.dart
        schedule_controller.dart
    voice/
      presentation/
        voice_floating_button.dart
        voice_record_panel.dart
        voice_controller.dart
    ai/
      presentation/
        ai_settings_page.dart
        ai_action_panel.dart
        ai_controller.dart
    settings/
      presentation/
        settings_page.dart
        security_settings_page.dart

assets/
  rive/
  lottie/
  images/
  icons/
  fonts/
```

### 6.5 核心数据流

所有页面交互必须通过 Application 层进入业务逻辑，不允许 UI 直接操作底层实现。例如保存笔记的调用链应为：

```text
NoteEditorPage
  ↓ 用户点击保存 / 自动保存触发
NoteEditorController
  ↓ 调用用例
UpdateNoteUseCase
  ↓ 调用领域仓库接口
NoteRepository
  ↓ 由基础设施层实现
NoteRepositoryImpl
  ↓
Drift Database + FileStore + CryptoService
```

语音随记的调用链应为：

```text
VoiceFloatingButton
  ↓ 控制录音 UI 动画
VoiceController
  ↓
SaveVoiceRecordUseCase
  ↓
AttachmentRepository + RecorderService
  ↓
本地音频文件 + 附件元数据
```

AI 转写或摘要的调用链应为：

```text
AIActionPanel
  ↓
TranscribeVoiceUseCase / SummarizeNoteUseCase
  ↓
AIConfigRepository + AIClient Interface
  ↓
OpenAICompatibleClient / 其他兼容服务商实现
```

### 6.6 UI 与核心功能的解耦规则

UI 层只消费 ViewModel 或 State，不直接消费数据库实体。领域实体用于表达核心业务，ViewModel 用于适配页面展示。这样后期更换卡片样式、时间线样式、编辑器布局和动效时，不会影响领域模型。

```text
Domain Entity：Note
  - id
  - title
  - content
  - folderId
  - createdAt
  - updatedAt

Presentation ViewModel：NoteCardViewModel
  - titleText
  - previewText
  - displayDate
  - folderColor
  - hasAudioBadge
  - hasReminderBadge
  - animationState
```

禁止在 UI 层维护核心数据的真实状态。UI 可以维护临时交互状态，例如卡片是否展开、动画是否播放、输入框是否聚焦，但笔记内容、附件关系、提醒状态和加密状态必须由 Application/Core 层维护。

### 6.7 动画层隔离要求

Rive 和 Lottie 必须被视为 UI 表现资源，不得承载业务规则。Rive 状态机可以响应业务状态，但不能反向决定核心业务结果。例如录音按钮的 Rive 状态可以根据 `recordingState` 切换 idle、recording、paused、saving，但“是否保存成功”必须来自 Application 层，而不是来自动画播放完成事件。

```text
业务状态：RecordingState.recording
        ↓
UI 映射：Rive StateMachine -> recording

业务状态：RecordingState.saved
        ↓
UI 映射：Lottie success animation
```

动画控制建议集中封装在 `ui_system/animations` 或各 feature 的 presentation 层中，不允许散落在业务用例中。

### 6.8 后期前端优化的可替换边界

后期优化前端时，允许直接替换以下内容而不影响核心功能：

```text
可替换：
- 页面布局
- 卡片样式
- 时间线视觉形态
- 主题系统
- Rive 动画文件
- Lottie 动画文件
- 页面转场
- 首页 Dashboard 组件组织
- 设置页展示方式
- 笔记列表筛选交互
```

不应在 UI 优化中被修改的内容包括：

```text
不应随 UI 改动而改变：
- Note / Folder / Attachment / ScheduleEvent 等领域实体
- Repository 接口契约
- 数据库迁移逻辑
- 加密密钥管理
- 附件文件路径规则
- 导出规则
- 提醒调度规则
- AI API Key 安全存储规则
```

### 6.9 面向未来 Server-Driven UI 的预留

如果后续希望服务端或配置文件动态调整首页、设置页、功能入口，可以只在 Presentation 层增加 UI Schema Renderer。该 Renderer 只能调用既有 Application UseCase，不得绕过业务层直接访问数据库或插件。

推荐预留结构如下：

```text
Remote / Local UI Schema
        ↓
UIScreenRenderer
        ↓
UI Components
        ↓
Action Dispatcher
        ↓
Application UseCases
        ↓
Domain / Infrastructure
```

这意味着未来即使将首页改成服务端配置，也只是替换 UI 组织方式，而不是替换业务核心。

### 6.10 接口示例

仓库接口应定义在 Domain 层：

```dart
abstract class NoteRepository {
  Future<Note> create(NoteDraft draft);
  Future<Note> update(Note note);
  Future<void> delete(NoteId id);
  Future<Note?> findById(NoteId id);
  Stream<List<Note>> watchByFolder(FolderId folderId);
}
```

用例定义在 Application 层：

```dart
class UpdateNoteUseCase {
  final NoteRepository noteRepository;

  UpdateNoteUseCase(this.noteRepository);

  Future<Note> call(UpdateNoteCommand command) async {
    final note = command.toDomain();
    note.validate();
    return noteRepository.update(note);
  }
}
```

页面控制器只调用用例，不接触数据库实现：

```dart
class NoteEditorController extends AsyncNotifier<NoteEditorState> {
  Future<void> saveDraft() async {
    final command = buildUpdateCommandFromState();
    await ref.read(updateNoteUseCaseProvider).call(command);
  }
}
```

### 6.11 验收标准

架构验收时必须满足以下条件：

```text
1. domain 层不得 import flutter、drift、http、path_provider 等框架或插件包。
2. application 层不得出现 Widget、BuildContext、AnimationController。
3. presentation 层不得直接调用 SQLite、File、Crypto、HTTP、Notification 插件。
4. 所有数据库访问必须经过 Repository 或 DAO 封装。
5. 所有导出、加密、录音、提醒、AI 请求必须通过明确的 service/interface 调用。
6. 替换 NoteCard、Timeline、VoiceButton 的 UI 实现时，不应修改 domain 和 infrastructure 层。
7. 新增一种 AI 服务商时，不应修改 UI 页面，只应增加 AIClient 实现和配置映射。
8. 新增一种导出格式时，不应修改笔记编辑页面核心逻辑，只应增加 Exporter 实现和入口配置。
```

---

## 7. 核心功能需求

## 7.1 首页 Dashboard

### 功能说明

首页是用户进入 App 后的主操作中心，应展示最近笔记、今日行程、快速入口、语音随记按钮和常用文件夹。首页必须具备较强的视觉表现，使用卡片、柔和动效和微交互形成高质量体验。

### 页面组成

首页应包含顶部问候区、搜索入口、最近笔记卡片、今日行程卡片、快速新建按钮、语音随记悬浮按钮、文件夹快捷入口和设置入口。顶部区域可以显示日期、当前问候语和今日待办概览。

### 交互要求

用户点击最近笔记卡片进入编辑页；点击今日行程进入时间线；点击新建按钮可以选择新建笔记、新建行程或新建语音随记；长按语音按钮进入录音状态；点击搜索栏进入全局搜索。

### 动画要求

首页加载时卡片应采用渐入和轻微上移动画。语音按钮应使用 Rive 状态机表现 idle、pressed、recording、processing、success、error 六种状态。空状态可使用 Lottie 动画。卡片点击应有轻微缩放反馈，页面跳转使用 Hero 或共享元素转场。

### 验收标准

首页首屏加载应流畅，普通设备上不得出现明显卡顿。点击核心入口后页面响应应即时。语音按钮状态切换应与录音状态同步，不允许出现动画状态与业务状态不一致的问题。

---

## 7.2 文件夹管理

### 功能说明

文件夹用于组织笔记。用户可以创建、重命名、删除和排序文件夹。每条笔记必须属于一个默认文件夹或用户自定义文件夹。删除文件夹时需要处理其下笔记，可选择移动到默认文件夹或一并删除。

### 功能项

用户可以创建文件夹，设置文件夹名称、图标和颜色。用户可以修改文件夹顺序。文件夹列表应显示文件夹名称、笔记数量和最近更新时间。系统应内置默认文件夹，例如“全部笔记”“未分类”“归档”。默认系统文件夹不能被删除。

### 数据规则

文件夹名称不能为空，同级文件夹名称不应重复。删除文件夹时需要弹出确认对话框。若用户选择删除文件夹和其中笔记，笔记先进入回收站，而不是立即永久删除。

### 动画要求

文件夹卡片进入、删除、拖拽排序时应有平滑动效。删除确认可使用底部弹窗，弹窗出现时背景轻微模糊或变暗。

---

## 7.3 笔记列表

### 功能说明

笔记列表展示指定文件夹或全部笔记中的内容。列表应支持搜索、排序、筛选、批量操作和笔记预览。笔记卡片应展示标题、摘要、更新时间、附件标识、标签和是否包含提醒。

### 排序与筛选

支持按更新时间、创建时间、标题、是否置顶排序。支持筛选含图片、含音频、含提醒、已归档、已删除和标签条件。首期可先实现更新时间排序和基础搜索，复杂筛选作为增强功能。

### 交互要求

点击笔记卡片进入编辑器。长按笔记卡片进入多选模式。左滑可显示归档、删除或移动操作。置顶笔记应显示明显标识。删除笔记时进入回收站。

### 动画要求

列表滚动应保持 60fps 体验。卡片插入、删除和重新排序使用 AnimatedList 或等效动画。长按进入多选模式时，卡片应出现选择状态动画。

---

## 7.4 富文本笔记编辑器

### 功能说明

富文本编辑器是产品核心模块。编辑器应支持标题、正文、加粗、斜体、下划线、列表、待办、引用、分割线、图片、音频附件和基础块结构。编辑内容应自动保存，并具备编辑状态提示。

### 基础编辑能力

编辑器必须支持纯文本输入、多段落编辑、撤销重做、标题样式、列表、待办项、图片插入、音频插入和链接插入。用户应能够在笔记中混合文本、图片和音频附件。

### 自动保存

编辑器应采用防抖自动保存机制。用户输入后短时间内自动保存，页面顶部或底部应显示“已保存”“保存中”“保存失败”等状态。若保存失败，需要保留本地草稿并提示用户。

### 附件处理

图片附件可以从相册选择或拍照添加。音频附件可以来自语音随记或手动录音。附件需要存储在应用私有目录，并在数据库中记录元数据。删除笔记时，附件不应立即物理删除，而应随笔记进入回收站。

### 导出能力

编辑器应支持将当前笔记导出为 PDF 和 PNG。PDF 应保留基础排版、图片和文本结构。PNG 可以导出当前笔记渲染结果或长图。导出时应提供预览和分享入口。

### 动画要求

工具栏展开、块插入、图片加载、音频卡片播放状态、保存状态变化应具备轻量动效。成功保存可使用微弱状态反馈，不应过度打扰用户。

### 验收标准

用户输入内容后退出页面，再次进入内容必须完整保留。插入图片和音频后，重启 App 仍可正常查看。导出 PDF/PNG 后文件可被系统分享和打开。编辑器在千字级笔记中应保持流畅。

---

## 7.5 时间线行程管理

### 功能说明

行程管理采用时间线形式展示事件、计划、提醒和任务。用户可以创建行程，设置标题、时间、地点、备注、提醒时间、重复规则和关联笔记。时间线应按日期组织，突出今日和即将发生的事项。

### 行程字段

每条行程至少包含标题、开始时间、结束时间、是否全天、地点、备注、提醒时间、状态、创建时间和更新时间。增强字段包括标签、关联笔记、重复规则、优先级和颜色。

### 时间线展示

时间线页面应支持按日、周、月查看。首期优先实现按日和按时间顺序展示。今日事项应默认展开，过期事项可弱化显示。用户点击时间线节点进入详情页。

### 编辑能力

用户可以创建、编辑、删除行程。行程详情页支持修改时间、地点、备注和提醒。删除行程需要确认。若行程关联提醒，需要同步取消本地通知。

### 动画要求

时间线节点展开使用 Flutter 动画。节点状态变化，如完成、过期、提醒触发，可使用 Rive 或 Lottie 表现。日期切换应有平滑横向过渡。新增行程后节点应从时间线中自然插入。

### 验收标准

创建行程后，时间线中应立即出现该事项。设置提醒后，系统应在指定时间触发本地通知。编辑行程时间后，提醒应同步更新。删除行程后，不应残留通知。

---

## 7.6 语音随记

### 功能说明

语音随记是本产品的重要快速入口。用户可以通过首页悬浮话筒按钮快速录音，录音完成后生成一条语音笔记。若用户配置了 AI API，可自动或手动转写为文本，并插入笔记正文。

### 录音流程

用户长按或点击话筒按钮进入录音状态。录音过程中显示实时状态、时长和波形动画。用户可以停止、取消或保存录音。保存后系统生成一条包含音频附件的笔记，标题可自动生成，例如“语音随记 2026-xx-xx xx:xx”。

### 转写流程

若用户启用 AI 转写，录音保存后进入处理状态。系统调用用户配置的语音模型接口，返回文本后写入笔记正文。若转写失败，音频仍应保存，用户可稍后重试。

### 动画要求

语音按钮必须使用 Rive 状态机。状态至少包括 idle、recording、paused、processing、success、error。录音波形可使用 Flutter 自绘或 Rive。转写处理中可以使用 Lottie 或 Rive AI 思考动画。

### 权限要求

首次使用录音时请求麦克风权限。用户拒绝权限时显示清晰说明，并提供跳转系统设置的入口。权限请求不应在 App 首次启动时弹出，而应在用户首次触发录音时弹出。

### 验收标准

录音文件必须成功保存，并可在笔记中播放。录音中断、来电、应用进入后台等异常情况需要保留已录制内容或给出明确提示。没有配置 AI API 时，语音随记仍应可用。

---

## 7.7 AI API 配置与 AI 功能

### 功能说明

AI 能力由用户自行配置 API。系统提供通用 OpenAI-compatible 接口配置方式，同时允许保存多个服务商配置。首期 AI 功能包括语音转写、笔记摘要、内容润色、待办提取和标题生成。

### 配置项

AI 设置页至少包含服务商名称、API Base URL、API Key、文本模型名称、语音模型名称、默认温度、请求超时、是否启用代理、是否自动转写语音、是否自动生成标题。API Key 必须加密保存，不允许明文显示。用户可以点击“测试连接”验证配置是否可用。

### AI 功能项

用户可以在笔记编辑器中调用 AI 摘要，将长笔记压缩为结构化摘要。用户可以调用 AI 润色，对选中文本进行语言优化。用户可以调用 AI 提取待办，将笔记中的任务转换为 checklist。用户可以基于笔记内容生成标题。

### 异常处理

API 请求失败时，应显示失败原因，例如网络错误、认证失败、模型不存在、余额不足或超时。系统不应丢失用户原文。AI 返回内容必须由用户确认后再覆盖原内容。

### 安全要求

AI API Key 仅保存在本地安全存储中。调用 AI 时，应明确告知用户所选内容会发送到配置的第三方 API。默认情况下，不自动上传全部笔记内容，除非用户主动启用相关功能。

---

## 7.8 本地提醒与通知

### 功能说明

本地提醒用于行程提醒和笔记提醒。用户可以为行程或笔记设置提醒时间，到时由系统通知用户。提醒功能不依赖服务器。

### 提醒类型

支持一次性提醒。后续可以扩展重复提醒，例如每天、每周、每月、自定义间隔。首期如果实现重复提醒，应保证删除或修改事项后重复通知同步更新。

### 通知内容

通知标题应显示行程或笔记标题，内容显示摘要或备注。用户点击通知后应跳转到对应行程详情或笔记详情。若目标内容已删除，点击通知后应显示内容不存在或已被删除。

### 权限要求

通知权限应在用户首次设置提醒时请求，而不是首次启动时请求。若用户拒绝权限，系统应允许保存提醒配置，但提示通知无法触发。

---

## 7.9 搜索功能

### 功能说明

搜索用于快速查找笔记、文件夹、行程和标签。首期实现本地关键词搜索，后续可扩展全文索引和语义搜索。

### 搜索范围

搜索范围包括笔记标题、笔记正文纯文本、文件夹名称、行程标题、行程备注和标签。搜索结果应按类型分组展示。

### 交互要求

用户点击搜索框进入搜索页。输入关键词后实时显示结果。搜索结果中应高亮关键词。点击结果进入对应详情页。

### 验收标准

搜索结果应准确返回包含关键词的内容。删除或修改笔记后，搜索结果应同步更新。空搜索状态应显示最近访问或搜索建议。

---

## 7.10 导出与分享

### 功能说明

导出功能用于将笔记输出为 PDF 或 PNG。用户可以在编辑器或详情页触发导出。导出后可预览、保存到本地或调用系统分享。

### PDF 导出

PDF 应包含标题、正文、图片、时间信息和基本排版。音频附件在 PDF 中可以显示为音频卡片占位，不需要嵌入可播放音频。PDF 文件名默认使用笔记标题和导出时间。

### PNG 导出

PNG 导出支持当前可视区域截图和长图导出。首期优先实现长图导出。导出长图时应保留背景、卡片样式和主要排版。

### 验收标准

导出的 PDF 可被系统文件管理器打开。导出的 PNG 清晰无明显截断。长笔记导出时应有加载提示，失败时给出明确提示。

---

## 7.11 本地加密与安全

### 功能说明

本地加密用于保护笔记正文、附件、AI API Key 和用户配置。首期至少需要保证 API Key 安全存储，笔记数据库和附件具备加密或私有目录保护策略。

### 安全等级

基础安全等级要求使用应用私有目录存储数据，其他应用无法直接访问。增强安全等级要求数据库加密、附件文件加密和应用锁。应用锁可支持密码、PIN 或系统生物识别。

### 应用锁

用户可以在设置中启用应用锁。启用后，每次冷启动或超过一定时间后台后再次打开 App，需要验证。验证方式优先使用系统生物识别，失败后可使用 PIN。

### 数据保护

删除笔记时默认进入回收站，用户手动清空回收站后再永久删除数据库记录和附件文件。导出文件属于用户主动输出，不再受应用加密保护，导出前应提示。

---

## 8. UI/UX 设计要求

## 8.1 总体视觉风格

视觉风格应采用现代、轻量、柔和、高级感的设计语言。整体应避免强烈高饱和颜色，优先使用低饱和背景、圆角卡片、柔和阴影、清晰层级和细腻动效。App 应支持浅色模式和深色模式。主题色可由用户在设置中选择。

## 8.2 页面布局原则

页面布局应以卡片为基本组织单元。首页强调信息概览和快速操作，笔记列表强调阅读效率，编辑器强调低干扰输入，时间线强调时间关系和状态变化。所有页面应保持一致的间距、圆角、字体层级和图标风格。

## 8.3 交互原则

交互应遵循即时反馈原则。点击、长按、滑动、拖拽、保存、删除、导出、录音和 AI 处理均需要有明确反馈。反馈不应过度打扰用户，重要操作使用确认弹窗，普通操作使用轻提示或状态变化。

## 8.4 动效原则

动效应服务于状态表达和空间关系，不应为了炫技而影响效率。核心动效包括页面转场、卡片展开、列表插入删除、语音按钮状态、时间线节点变化、导出成功和空状态提示。

## 8.5 Rive 使用规范

Rive 只用于具有状态机和交互反馈需求的动画。每个 Rive 动画文件应定义明确的状态输入，例如 `isRecording`、`isProcessing`、`successTrigger`、`errorTrigger`。业务层状态变化必须驱动 Rive 状态，而不是由动画自行决定业务流程。

推荐 Rive 场景包括语音按钮、录音波形、AI 思考状态、时间线节点完成动画、首页启动引导和重要按钮反馈。

## 8.6 Lottie 使用规范

Lottie 用于非交互或弱交互动画。Lottie 动画不应承担业务状态机，只用于表达加载、成功、失败、空状态和插画。Lottie 文件应控制大小，避免过大的 JSON 动画影响启动性能。

推荐 Lottie 场景包括空文件夹、暂无行程、导出成功、加载中、网络错误、无搜索结果和首次使用引导。

---

## 9. 页面清单

| 页面 | 路由建议 | 优先级 | 说明 |
|---|---|---:|---|
| 启动页 | `/splash` | P0 | 初始化数据库、主题、安全锁 |
| 首页 | `/home` | P0 | 最近笔记、今日行程、语音入口 |
| 笔记列表 | `/notes` | P0 | 展示全部或文件夹内笔记 |
| 笔记编辑 | `/notes/:id/edit` | P0 | 富文本编辑、附件、导出 |
| 新建笔记 | `/notes/new` | P0 | 创建新笔记 |
| 文件夹页 | `/folders` | P0 | 文件夹管理 |
| 时间线页 | `/schedule` | P0 | 行程时间线 |
| 行程详情 | `/schedule/:id` | P0 | 查看和编辑行程 |
| 语音随记页 | `/voice` | P0 | 录音、保存、转写 |
| 搜索页 | `/search` | P1 | 全局搜索 |
| 设置页 | `/settings` | P0 | 全局配置入口 |
| AI 设置页 | `/settings/ai` | P0 | API 配置和测试 |
| 安全设置页 | `/settings/security` | P1 | 应用锁、加密设置 |
| 导出预览页 | `/export/preview` | P1 | PDF/PNG 预览 |
| 回收站 | `/trash` | P1 | 恢复或永久删除 |
| 主题设置 | `/settings/theme` | P2 | 主题色、深浅色 |

---

## 10. 数据模型设计

## 10.1 Folder

```text
Folder
- id: String
- name: String
- icon: String?
- color: String?
- sortOrder: int
- isSystem: bool
- createdAt: DateTime
- updatedAt: DateTime
```

## 10.2 Note

```text
Note
- id: String
- folderId: String
- title: String
- plainText: String
- richContent: String / JSON
- isPinned: bool
- isArchived: bool
- isDeleted: bool
- deletedAt: DateTime?
- createdAt: DateTime
- updatedAt: DateTime
- lastOpenedAt: DateTime?
```

## 10.3 Attachment

```text
Attachment
- id: String
- noteId: String
- type: image | audio | file
- fileName: String
- localPath: String
- mimeType: String
- sizeBytes: int
- durationMs: int?
- width: int?
- height: int?
- createdAt: DateTime
```

## 10.4 ScheduleEvent

```text
ScheduleEvent
- id: String
- title: String
- description: String?
- location: String?
- startTime: DateTime
- endTime: DateTime?
- isAllDay: bool
- reminderTime: DateTime?
- status: pending | completed | cancelled
- relatedNoteId: String?
- createdAt: DateTime
- updatedAt: DateTime
```

## 10.5 Reminder

```text
Reminder
- id: String
- targetType: note | schedule
- targetId: String
- triggerTime: DateTime
- notificationId: int
- enabled: bool
- createdAt: DateTime
- updatedAt: DateTime
```

## 10.6 AIProviderConfig

```text
AIProviderConfig
- id: String
- name: String
- baseUrl: String
- encryptedApiKey: String
- textModel: String
- speechModel: String?
- temperature: double
- timeoutSeconds: int
- isDefault: bool
- createdAt: DateTime
- updatedAt: DateTime
```

## 10.7 AppSettings

```text
AppSettings
- id: String
- themeMode: system | light | dark
- themeColor: String
- enableAppLock: bool
- autoTranscribeVoice: bool
- defaultFolderId: String
- exportIncludeMetadata: bool
- createdAt: DateTime
- updatedAt: DateTime
```

---

## 11. 权限需求

| 权限 | 触发场景 | 是否首启请求 | 说明 |
|---|---|---:|---|
| 麦克风 | 首次录音 | 否 | 用户触发语音随记时请求 |
| 通知 | 首次设置提醒 | 否 | 用户创建提醒时请求 |
| 相册/图片 | 插入图片 | 否 | 选择图片时请求 |
| 相机 | 拍照插入 | 否 | 后续增强功能 |
| 文件访问 | 导出/分享 | 否 | 通过系统文件选择或分享能力实现 |
| 生物识别 | 启用应用锁 | 否 | 用户主动开启安全功能时请求 |

权限请求必须具备清晰解释。用户拒绝权限后，相关功能应降级，而不是导致 App 崩溃或核心功能不可用。

---

## 12. 非功能需求

## 12.1 性能需求

首页冷启动应尽量控制在合理时间内，数据库初始化和资源加载不应阻塞主线程。笔记列表应支持至少数千条笔记的流畅滚动。图片缩略图应异步加载并缓存。Rive 和 Lottie 动画文件应控制体积，避免同时加载大量动画。

## 12.2 稳定性需求

App 不应因 AI API 失败、录音中断、导出失败、权限拒绝、数据库写入失败而崩溃。所有关键写操作应具备异常捕获和用户提示。自动保存需要保证数据一致性，避免重复保存导致内容回退。

## 12.3 隐私需求

默认不上传任何笔记、音频、图片和行程数据。只有用户主动使用 AI 功能时，才将选定内容发送到用户配置的 API 服务。所有隐私相关设置应在设置页可见。

## 12.4 可维护性需求

项目必须采用模块化目录结构，并严格执行 UI 层与核心功能层分离。UI 层可以独立优化布局、主题、动画和交互，但不得改变领域实体、仓库接口、数据库迁移、加密策略和导出规则。每个 feature 应通过 controller/provider 调用 application use case，禁止在页面 Widget 中直接编写数据库、网络、文件系统、加密或通知逻辑。核心业务流程必须通过 use case、repository interface 和 service interface 封装。

每次新增功能时，必须先判断该能力属于 Presentation、Application、Domain 还是 Infrastructure/Data。若一个功能同时涉及 UI 与底层能力，应先定义领域接口和用例，再开发页面；不得先在页面中堆叠逻辑后再抽取。

## 12.5 可测试性需求

数据层和业务层应具备单元测试能力。关键用例包括创建笔记、保存笔记、移动文件夹、创建行程、设置提醒、保存录音、导出、AI 配置加密保存。UI 测试可优先覆盖首页、编辑器和时间线核心路径。

---

## 13. 错误处理与边界场景

### 13.1 数据保存失败

当笔记保存失败时，系统应显示“保存失败，已保留本地草稿”。草稿应缓存在本地临时表或文件中，避免用户输入丢失。

### 13.2 录音中断

当录音过程中 App 进入后台、权限被撤销或系统中断录音时，应尽可能保存已录制片段。如果无法保存，应给出明确提示。

### 13.3 AI 请求失败

AI 请求失败不能影响原始笔记。系统应显示错误信息，并允许用户重试。错误信息应尽量可读，例如“API Key 无效”“请求超时”“模型不存在”。

### 13.4 导出失败

导出失败时应给出失败原因。若是权限问题，引导用户授权；若是内容过大，提示分段导出或降低图片质量。

### 13.5 数据库迁移失败

数据库版本升级时必须做好迁移策略。迁移失败时应阻止继续写入，并提示用户备份数据或重试。不得静默清空数据库。

---

## 14. 开发优先级

### P0：核心闭环

P0 阶段必须完成首页、笔记创建、富文本编辑、文件夹管理、本地保存、图片附件、音频附件、时间线行程、提醒、语音录音、设置页和基础加密。没有这些能力，产品不能形成可用闭环。

### P1：体验增强

P1 阶段完成搜索、PDF/PNG 导出、AI API 配置、语音转写、应用锁、回收站、深色模式、关键 Rive 动画和 Lottie 空状态。

### P2：高级增强

P2 阶段完成复杂主题系统、标签系统、模板、语义搜索、重复提醒、Markdown 导入导出、更多 AI 功能、局部远程配置和跨设备同步预留。

---

## 15. 里程碑规划

## 15.1 M1：项目基础架构

完成 Flutter 项目初始化、路由、主题、状态管理、本地数据库、基础目录结构、错误处理框架和日志系统。该阶段不追求完整 UI，但必须建立可维护架构。

## 15.2 M2：笔记核心功能

完成文件夹、笔记列表、笔记编辑、自动保存、图片附件、音频附件和本地数据持久化。该阶段完成后，用户可以实际使用 App 记录内容。

## 15.3 M3：时间线与提醒

完成行程时间线、行程详情、提醒设置、本地通知和通知跳转。该阶段完成后，App 具备笔记 + 行程双核心。

## 15.4 M4：语音随记与 AI 配置

完成语音录制、语音保存、AI API 配置、连接测试、语音转写、标题生成和摘要生成。该阶段完成后，App 具备智能输入能力。

## 15.5 M5：视觉动效与导出

完成 Rive 语音按钮、时间线动效、Lottie 空状态、页面转场、PDF 导出、PNG 导出和分享能力。该阶段完成后，App 具备明显的产品质感。

## 15.6 M6：安全与打磨

完成应用锁、敏感配置加密、回收站、异常处理、性能优化、测试覆盖、权限提示和发布构建配置。

---

## 16. Agent 开发任务拆分

### 16.1 第一阶段任务

Agent 应先创建 Flutter 项目骨架，配置 Riverpod、go_router、本地数据库、主题系统和基础页面路由。不要先实现复杂动画，也不要过早接入 AI。第一阶段目标是让 App 能运行、能跳转、能保存基础数据。

### 16.2 第二阶段任务

实现 Note、Folder、Attachment 的数据模型、数据库表、Repository 和基础页面。实现新建笔记、编辑笔记、保存笔记、笔记列表、文件夹筛选和删除到回收站。

### 16.3 第三阶段任务

实现 ScheduleEvent 和 Reminder 模型，完成时间线页面、行程详情页、本地通知注册、通知取消和通知点击跳转。

### 16.4 第四阶段任务

实现语音录制模块，完成录音权限、录音文件保存、音频播放、语音笔记创建和录音状态 UI。随后接入 Rive 语音按钮状态机。

### 16.5 第五阶段任务

实现 AI 配置页，完成 API Key 安全保存、Base URL 配置、模型配置、连接测试、语音转写接口、笔记摘要接口和错误提示。

### 16.6 第六阶段任务

实现 PDF/PNG 导出、系统分享、Lottie 空状态、页面动画、主题切换、应用锁和基础测试。

---

## 17. Agent 开发约束

Agent 在开发时必须遵守以下约束：不得将数据库操作直接写入 Widget；不得将 API Key 明文存储；不得在 App 首次启动时请求所有权限；不得将 AI 功能作为核心功能阻塞项；不得在一个文件中堆叠过多页面逻辑；不得让 Rive / Lottie 动画承担业务判断；不得在没有用户确认的情况下覆盖笔记原文；不得静默删除用户数据。

Agent 每实现一个功能模块，必须同时给出其所在层级：Presentation、Application、Domain 或 Infrastructure/Data。若修改 UI，只允许改动 `features/*/presentation` 或 `ui_system`；若修改数据库、文件、加密、提醒或 AI 请求，必须通过 repository/service 接口完成。不得为了实现一个按钮点击而从页面直接调用数据库、文件系统、HTTP 客户端或通知插件。

所有核心功能必须先完成可用性，再做视觉优化。动画文件应放在 `assets/rive` 和 `assets/lottie` 中，并在 `pubspec.yaml` 中明确声明。业务状态变化应通过状态管理层驱动 UI 和动画，不允许页面内部随意维护重复核心状态。

---

## 18. 验收用例

### 18.1 笔记闭环验收

用户可以创建文件夹，进入文件夹后新建笔记，输入富文本内容，插入图片和音频，退出页面后再次进入，所有内容完整保留。用户可以将该笔记导出为 PDF 和 PNG，并通过系统分享。

### 18.2 行程闭环验收

用户可以创建一条明天上午 9 点的行程，设置提前 10 分钟提醒。保存后该行程出现在时间线中。本地通知应在指定时间触发。用户点击通知后进入对应行程详情。

### 18.3 语音随记验收

用户点击或长按首页话筒按钮开始录音。录音过程中 Rive 动画进入 recording 状态。停止录音后生成一条语音笔记，用户可以播放音频。若已配置 AI，则可以转写为文本；若未配置 AI，则语音笔记仍然保存成功。

### 18.4 AI 配置验收

用户在设置页输入 Base URL、API Key 和模型名称，点击测试连接后获得成功或失败提示。API Key 不应在数据库中明文出现。调用摘要功能时，原文不被覆盖，AI 输出需要用户确认插入。

### 18.5 安全验收

用户开启应用锁后，冷启动 App 需要验证。导出笔记时，系统提示导出文件不再受应用内部加密保护。删除笔记后，笔记进入回收站，清空回收站后附件文件被同步删除。

---

## 19. 推荐技术组合

| 模块 | 推荐方案 | 备注 |
|---|---|---|
| 主框架 | Flutter | Android/iOS 统一 UI |
| 语言 | Dart | Flutter 默认语言 |
| 状态管理 | Riverpod | 推荐统一使用 |
| 路由 | go_router | 支持命名路由和深链接扩展 |
| 数据库 | Drift + SQLite | 适合关系型数据和迁移 |
| 动画 | Rive + Lottie + Flutter Animation | 分别处理交互动画、状态动画和页面动效 |
| 富文本 | Flutter 编辑器或 WebView 嵌入编辑器 | 根据复杂度选择 |
| 录音 | Flutter 录音插件 | 需封装权限与异常 |
| 音频播放 | Flutter 音频播放插件 | 用于笔记内音频附件 |
| 通知 | flutter_local_notifications | 本地提醒 |
| 安全存储 | secure storage 方案 | 保存 API Key 和密钥 |
| 导出 PDF | PDF 生成方案 | 支持笔记渲染导出 |
| PNG 导出 | 截图/长图生成方案 | 支持分享 |
| AI 请求 | HTTP 客户端封装 | 兼容 OpenAI-style API |

---

## 20. 设计风险与应对策略

### 20.1 富文本编辑器风险

Flutter 原生富文本生态相比 Web 端复杂编辑器仍有差距。若需要块编辑、拖拽、多媒体嵌入和复杂导出，建议保留 WebView 嵌入编辑器的备选方案。首期可以先实现基础富文本，避免一开始追求 Notion 级编辑器。

### 20.2 动画过度风险

Rive 和 Lottie 能增强体验，但过多动画会影响性能和开发效率。首期只对高价值场景加入动画，例如语音按钮、空状态、时间线节点和导出反馈。普通列表和设置项不需要复杂动画。

### 20.3 数据加密风险

加密会增加数据迁移和调试复杂度。首期可以采用分级策略，先保证 API Key 安全存储和应用私有目录隔离，再逐步增强数据库加密和附件加密。

### 20.4 AI 依赖风险

AI API 由用户自行配置，可能出现不可用、欠费、模型不兼容和网络失败。AI 功能必须是增强项，不能影响笔记、录音、行程和导出等本地能力。

### 20.5 跨平台差异风险

Android 和 iOS 对权限、通知、文件系统、后台任务和生物识别的规则不同。所有平台相关能力都应通过 service 层封装，不允许页面直接调用平台插件。

---

## 21. 首期 MVP 定义

首期 MVP 的目标不是完成所有高级能力，而是实现一个可以稳定自用的高质量单机版。MVP 应包含首页、文件夹、笔记列表、笔记编辑、图片附件、音频附件、时间线行程、本地提醒、语音随记、设置页、AI API 配置、本地保存、基础加密和基础动效。

MVP 可以暂缓复杂标签、模板市场、云同步、OCR、语义搜索、重复提醒、Markdown 完整兼容和高级块编辑器。MVP 完成后，应能满足用户每日记录、管理行程、保存语音、插入多媒体、导出内容和调用 AI 辅助整理的基本需求。

---

## 22. 最终推荐实现路线

建议采用 Flutter 作为主框架，优先建立稳定的数据层和功能闭环，再逐步加入 Rive 和 Lottie 视觉系统。Rive 应用于语音输入、AI 处理和时间线关键状态；Lottie 应用于空状态、加载、成功和错误反馈。富文本编辑器应先实现稳定可用版本，再根据实际需要决定是否升级为 WebView 嵌入的块编辑方案。

项目第一阶段不应追求“全动态 UI”或“全 AI 化”，而应先保证本地笔记、附件、行程、提醒和加密稳定可用。后续再加入远程配置、主题系统和更强 AI 工作流。这样的路线可以避免早期架构过度复杂，同时保留产品后续演进空间。

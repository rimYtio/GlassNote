import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/timeline/create_timeline_task_use_case.dart';
import '../../infrastructure/providers/infrastructure_providers.dart';

final createTimelineTaskUseCaseProvider = Provider<CreateTimelineTaskUseCase>((
  ref,
) {
  return CreateTimelineTaskUseCase(ref.watch(timelineTaskRepositoryProvider));
});

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';
import '../../../domain/entities/entities.dart';
import '../bloc/app_mgmt_bloc.dart';

class ApplicationDetailsPage extends StatelessWidget {
  final String projectId;
  final String applicationId;

  const ApplicationDetailsPage({
    super.key,
    required this.projectId,
    required this.applicationId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppMgmtBloc, AppMgmtState>(
      builder: (context, state) {
        final app = state.applications
            .firstWhere((a) => a.id == applicationId);

        final isPending =
            app.status == ApplicationStatus.pending;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(app.applicant.name),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(app.role, style: AppTypography.h3),
                const SizedBox(height: 12),
                Text(app.motivation),
                const Spacer(),
                if (isPending)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => context
                              .read<AppMgmtBloc>()
                              .add(AppMgmtApplicationAccepted(app.id)),
                          child: const Text('Принять'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => context
                              .read<AppMgmtBloc>()
                              .add(AppMgmtApplicationRejected(app.id)),
                          child: const Text('Отклонить'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
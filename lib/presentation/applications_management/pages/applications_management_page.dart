import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/entities.dart';
import '../../common/widgets/common_widgets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';
import '../bloc/app_mgmt_bloc.dart';

class ApplicationsManagementPage extends StatefulWidget {
  final String projectId;
  const ApplicationsManagementPage({super.key, required this.projectId});

  @override
  State<ApplicationsManagementPage> createState() =>
      _ApplicationsManagementPageState();
}

class _ApplicationsManagementPageState
    extends State<ApplicationsManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<AppMgmtBloc>().add(
          AppMgmtLoadRequested(widget.projectId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppMgmtBloc, AppMgmtState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: TabBarView(
            controller: _tabController,
            children: [
              _AppList(apps: state.pending, projectId: widget.projectId),
              _AppList(apps: state.accepted, projectId: widget.projectId),
              _AppList(apps: state.rejected, projectId: widget.projectId),
            ],
          ),
        );
      },
    );
  }
}

class _AppList extends StatelessWidget {
  final List<ApplicationEntity> apps;
  final String projectId;

  const _AppList({
    required this.apps,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    if (apps.isEmpty) {
      return const Center(child: Text('Нет заявок'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.md),
      itemCount: apps.length,
      itemBuilder: (context, i) {
        final app = apps[i];

        return ListTile(
          onTap: () => context.push(
              '/project/$projectId/applications/${app.id}'),
          title: Text(app.applicant.name),
          subtitle: Text(app.role),
          trailing: app.status == ApplicationStatus.pending
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () => context
                          .read<AppMgmtBloc>()
                          .add(AppMgmtApplicationAccepted(app.id)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => context
                          .read<AppMgmtBloc>()
                          .add(AppMgmtApplicationRejected(app.id)),
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }
}
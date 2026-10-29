import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:test_grid_app/core/repositories/task_repository.dart';
import 'package:test_grid_app/screens/home_screen/home_cubit.dart';
import 'package:test_grid_app/screens/home_screen/widgets/saved_urls_dropdown.dart';
import 'package:test_grid_app/screens/process_screen/process_screen.dart';
import 'package:test_grid_app/widgets/bottom_action_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _urlController = TextEditingController();
  String? _selectedHistoryUrl;
  String? _urlError;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _start() {
    final value = _urlController.text.trim();
    final uri = Uri.tryParse(value);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      setState(() => _urlError = 'Enter a valid full HTTPS URL.');
      return;
    }

    setState(() => _urlError = null);
    final repository = context.read<TaskRepository>();
    Navigator.of(context)
        .push<void>(
          MaterialPageRoute(
            builder: (_) => ProcessScreen(uri: uri, repository: repository),
          ),
        )
        .then((_) {
          if (mounted) context.read<HomeCubit>().loadSuccessfulUrls();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home screen')),
      bottomNavigationBar: BottomActionButton(
        buttonKey: const ValueKey('start_button'),
        onPressed: _start,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_arrow_rounded),
            SizedBox(width: 8),
            Text('Start'),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Icon(
                Icons.route_rounded,
                size: 56,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                'Find the shortest path',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the full API URL to load and solve grid tasks.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state.successfulUrls.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: SavedUrlsDropdown(
                      urls: state.successfulUrls,
                      selectedUrl: _selectedHistoryUrl,
                      onChanged: (url) {
                        if (url == null) return;
                        setState(() {
                          _selectedHistoryUrl = url;
                          _urlController.text = url;
                          _urlError = null;
                        });
                      },
                    ),
                  );
                },
              ),
              TextFormField(
                key: const ValueKey('api_url_field'),
                controller: _urlController,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                onChanged: (_) => setState(() {
                  _selectedHistoryUrl = null;
                  _urlError = null;
                }),
                onFieldSubmitted: (_) => _start(),
                decoration: InputDecoration(
                  labelText: 'Full API URL',
                  hintText: 'Paste the API URL here',
                  prefixIcon: const Icon(Icons.link),
                  border: const OutlineInputBorder(),
                  errorText: _urlError,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

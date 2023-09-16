import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final loadingProvider = StateProvider<bool>((ref) => false);

class LoadingManager extends ConsumerWidget {
  const LoadingManager({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(loadingProvider);
    return Stack(
      children: [
        child,
        isLoading
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: Colors.black.withOpacity(0.7),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}

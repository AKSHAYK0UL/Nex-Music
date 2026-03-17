import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/sleep_timer_bloc/bloc/sleep_timer_bloc.dart';
import 'package:nex_music/model/sleep_timer_model.dart';

class SleepTimerIndicator extends StatelessWidget {
  const SleepTimerIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SleepTimerBloc, SleepTimerState>(
      builder: (context, state) {
        final timerInfo = SleepTimerInfo.fromState(state);

        if (!timerInfo.isActive) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F7).withValues(alpha: 0.60),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 50,
                offset: const Offset(0, 10),
              ),
            ],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
          ),
          child: IntrinsicWidth(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.timer,
                  size: 20,
                  color: Colors.red.shade700,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    timerInfo.formattedRemainingTime,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontFamily: 'monospace',
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    context.read<SleepTimerBloc>().add(StopTimerEvent());
                  },
                  child: Icon(
                    CupertinoIcons.xmark_circle_fill,
                    size: 20,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

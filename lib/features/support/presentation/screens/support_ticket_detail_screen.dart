import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../domain/models/support_ticket_model.dart';
import '../providers/support_provider.dart';

class SupportTicketDetailScreen extends ConsumerStatefulWidget {
  final String ticketUuid;

  const SupportTicketDetailScreen({
    super.key,
    required this.ticketUuid,
  });

  @override
  ConsumerState<SupportTicketDetailScreen> createState() => _SupportTicketDetailScreenState();
}

class _SupportTicketDetailScreenState extends ConsumerState<SupportTicketDetailScreen> {
  late final TextEditingController _replyController;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _replyController = TextEditingController();
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _sendReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);

    try {
      final repo = ref.read(supportRepositoryProvider);
      await repo.replyToTicket(widget.ticketUuid, text);
      _replyController.clear();
      ref.invalidate(supportTicketDetailProvider(widget.ticketUuid));
    } catch (_) {} finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final l10n = context.l10n;
    final ticketAsync = ref.watch(supportTicketDetailProvider(widget.ticketUuid));

    return Scaffold(
      backgroundColor: isDark ? AppColors.canvasDark : AppColors.canvasLight,
      appBar: AppBar(
        title: const Text('Support Ticket'),
      ),
      body: ticketAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Could not load ticket details'),
              const SizedBox(height: 10),
              AppButton(
                label: l10n.retry,
                variant: AppButtonVariant.secondary,
                onPressed: () => ref.refresh(supportTicketDetailProvider(widget.ticketUuid)),
              ),
            ],
          ),
        ),
        data: (ticket) {
          final dateFormatted = DateFormat('dd MMM yyyy, hh:mm a').format(ticket.createdAt);

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.screenGutter),
                  children: [
                    // Status & Info Card
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.cardPadding),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        borderRadius: AppSpacing.roundedCard,
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Ticket #${ticket.uuid.substring(0, ticket.uuid.length > 8 ? 8 : ticket.uuid.length)}',
                                style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                              ),
                              StatusPill(
                                label: ticket.status.displayName,
                                type: ticket.status == TicketStatus.resolved
                                    ? StatusPillType.success
                                    : (ticket.status == TicketStatus.inProgress
                                        ? StatusPillType.warning
                                        : StatusPillType.neutral),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateFormatted,
                            style: AppTypography.caption.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ticket.title,
                            style: AppTypography.bodySmallMedium.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ticket.description,
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Refund notice if granted
                    if (ticket.refundAmount != null && ticket.refundAmount! > 0) ...[
                      const SizedBox(height: AppSpacing.m),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.cardPadding),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.successDark : AppColors.successLight).withValues(alpha: 0.12),
                          borderRadius: AppSpacing.roundedCard,
                          border: Border.all(
                            color: isDark ? AppColors.successDark : AppColors.successLight,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.currency_exchange_rounded,
                              color: isDark ? AppColors.successDark : AppColors.successLight,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Refund Approved',
                                    style: AppTypography.bodySmallMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? AppColors.successDark : AppColors.successLight,
                                    ),
                                  ),
                                  Text(
                                    '${AppConstants.defaultCurrencySymbol}${ticket.refundAmount!.toInt()} has been refunded to your original payment method.',
                                    style: AppTypography.caption,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.l),
                    Text(
                      'Conversation History',
                      style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppSpacing.s),

                    // Messages timeline
                    ...ticket.messages.map((msg) {
                      final isMe = msg.isFromCustomer;
                      final msgDate = DateFormat('hh:mm a').format(msg.timestamp);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe
                              ? primaryColor.withValues(alpha: 0.08)
                              : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                          borderRadius: AppSpacing.roundedCard,
                          border: Border.all(
                            color: isMe
                                ? primaryColor.withValues(alpha: 0.3)
                                : (isDark ? AppColors.borderDark : AppColors.borderLight),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isMe ? 'You' : 'PlateRoute Support Specialist',
                                  style: AppTypography.caption.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isMe ? primaryColor : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                                  ),
                                ),
                                Text(
                                  msgDate,
                                  style: AppTypography.caption.copyWith(
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(msg.text, style: AppTypography.bodySmall),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // Bottom Reply Field
              if (ticket.status != TicketStatus.closed)
                Container(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenGutter,
                    AppSpacing.xs,
                    AppSpacing.screenGutter,
                    AppSpacing.m,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    border: Border(
                      top: BorderSide(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _replyController,
                            decoration: InputDecoration(
                              hintText: 'Reply to support team...',
                              hintStyle: AppTypography.bodySmall.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: _isSending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(Icons.send_rounded, color: primaryColor),
                          onPressed: _isSending ? null : _sendReply,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

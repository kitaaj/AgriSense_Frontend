import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../constants/app_constants.dart';

enum ButtonType {
  primary,
  secondary,
  outline,
  text,
  danger,
}

enum ButtonSize {
  small,
  medium,
  large,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onPressed != null && !isLoading;

    // Get button colors based on type
    final colors = _getButtonColors(context);
    
    // Get button size properties
    final sizeProps = _getButtonSizeProperties();

    Widget buttonChild = _buildButtonContent(context);

    Widget button;

    switch (type) {
      case ButtonType.primary:
      case ButtonType.danger:
        button = ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? colors.backgroundColor,
            foregroundColor: textColor ?? colors.textColor,
            disabledBackgroundColor: Colors.grey[300],
            disabledForegroundColor: Colors.grey[600],
            elevation: isEnabled ? 2 : 0,
            shadowColor: colors.backgroundColor?.withValues(alpha:0.3),
            padding: EdgeInsets.symmetric(
              horizontal: sizeProps.horizontalPadding,
              vertical: sizeProps.verticalPadding,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                borderRadius ?? AppBorderRadius.md,
              ),
            ),
            minimumSize: isFullWidth ? const Size(double.infinity, 0) : null,
          ),
          child: buttonChild,
        );
        break;

      case ButtonType.secondary:
        button = ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? theme.colorScheme.secondary,
            foregroundColor: textColor ?? theme.colorScheme.onSecondary,
            disabledBackgroundColor: Colors.grey[300],
            disabledForegroundColor: Colors.grey[600],
            elevation: isEnabled ? 1 : 0,
            padding: EdgeInsets.symmetric(
              horizontal: sizeProps.horizontalPadding,
              vertical: sizeProps.verticalPadding,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                borderRadius ?? AppBorderRadius.md,
              ),
            ),
            minimumSize: isFullWidth ? const Size(double.infinity, 0) : null,
          ),
          child: buttonChild,
        );
        break;

      case ButtonType.outline:
        button = OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor ?? colors.backgroundColor,
            disabledForegroundColor: Colors.grey[600],
            side: BorderSide(
              color: isEnabled 
                ? (backgroundColor ?? colors.backgroundColor ?? theme.primaryColor)
                : Colors.grey[300]!,
              width: 1.5,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: sizeProps.horizontalPadding,
              vertical: sizeProps.verticalPadding,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                borderRadius ?? AppBorderRadius.md,
              ),
            ),
            minimumSize: isFullWidth ? const Size(double.infinity, 0) : null,
          ),
          child: buttonChild,
        );
        break;

      case ButtonType.text:
        button = TextButton(
          onPressed: isEnabled ? onPressed : null,
          style: TextButton.styleFrom(
            foregroundColor: textColor ?? colors.backgroundColor,
            disabledForegroundColor: Colors.grey[600],
            padding: EdgeInsets.symmetric(
              horizontal: sizeProps.horizontalPadding,
              vertical: sizeProps.verticalPadding,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                borderRadius ?? AppBorderRadius.md,
              ),
            ),
            minimumSize: isFullWidth ? const Size(double.infinity, 0) : null,
          ),
          child: buttonChild,
        );
        break;
    }

    return button;
  }

  Widget _buildButtonContent(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: _getButtonSizeProperties().iconSize,
        width: _getButtonSizeProperties().iconSize,
        child: SpinKitCircle(
          color: _getLoadingColor(context),
          size: _getButtonSizeProperties().iconSize,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: _getButtonSizeProperties().iconSize,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            text,
            style: TextStyle(
              fontSize: _getButtonSizeProperties().fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: _getButtonSizeProperties().fontSize,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  _ButtonColors _getButtonColors(BuildContext context) {
    final theme = Theme.of(context);
    
    switch (type) {
      case ButtonType.primary:
        return _ButtonColors(
          backgroundColor: theme.primaryColor,
          textColor: Colors.white,
        );
      case ButtonType.secondary:
        return _ButtonColors(
          backgroundColor: theme.colorScheme.secondary,
          textColor: theme.colorScheme.onSecondary,
        );
      case ButtonType.danger:
        return _ButtonColors(
          backgroundColor: theme.colorScheme.error,
          textColor: Colors.white,
        );
      case ButtonType.outline:
      case ButtonType.text:
        return _ButtonColors(
          backgroundColor: theme.primaryColor,
          textColor: theme.primaryColor,
        );
    }
  }

  _ButtonSizeProperties _getButtonSizeProperties() {
    switch (size) {
      case ButtonSize.small:
        return const _ButtonSizeProperties(
          horizontalPadding: AppSpacing.md,
          verticalPadding: AppSpacing.sm,
          fontSize: AppTextStyles.bodySmall,
          iconSize: 16,
        );
      case ButtonSize.medium:
        return const _ButtonSizeProperties(
          horizontalPadding: AppSpacing.lg,
          verticalPadding: AppSpacing.md,
          fontSize: AppTextStyles.bodyLarge,
          iconSize: 20,
        );
      case ButtonSize.large:
        return const _ButtonSizeProperties(
          horizontalPadding: AppSpacing.xl,
          verticalPadding: AppSpacing.lg,
          fontSize: AppTextStyles.titleMedium,
          iconSize: 24,
        );
    }
  }

  Color _getLoadingColor(BuildContext context) {
    switch (type) {
      case ButtonType.primary:
      case ButtonType.secondary:
      case ButtonType.danger:
        return Colors.white;
      case ButtonType.outline:
      case ButtonType.text:
        return backgroundColor ?? Theme.of(context).primaryColor;
    }
  }
}

class _ButtonColors {
  final Color? backgroundColor;
  final Color? textColor;

  const _ButtonColors({
    this.backgroundColor,
    this.textColor,
  });
}

class _ButtonSizeProperties {
  final double horizontalPadding;
  final double verticalPadding;
  final double fontSize;
  final double iconSize;

  const _ButtonSizeProperties({
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.fontSize,
    required this.iconSize,
  });
}

// Icon Button variant
class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? iconColor;
  final String? tooltip;

  const CustomIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.backgroundColor,
    this.iconColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onPressed != null && !isLoading;
    
    final sizeProps = _getButtonSizeProperties();
    final colors = _getButtonColors(context);

    Widget iconWidget = isLoading
        ? SpinKitCircle(
            color: iconColor ?? colors.textColor ?? Colors.white,
            size: sizeProps.iconSize,
          )
        : Icon(
            icon,
            size: sizeProps.iconSize,
            color: iconColor ?? colors.textColor,
          );

    Widget button;

    switch (type) {
      case ButtonType.primary:
      case ButtonType.secondary:
      case ButtonType.danger:
        button = ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? colors.backgroundColor,
            foregroundColor: iconColor ?? colors.textColor,
            disabledBackgroundColor: Colors.grey[300],
            disabledForegroundColor: Colors.grey[600],
            elevation: isEnabled ? 2 : 0,
            padding: EdgeInsets.all(sizeProps.verticalPadding),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            minimumSize: Size(
              sizeProps.iconSize + (sizeProps.verticalPadding * 2),
              sizeProps.iconSize + (sizeProps.verticalPadding * 2),
            ),
          ),
          child: iconWidget,
        );
        break;

      case ButtonType.outline:
        button = OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: iconColor ?? colors.backgroundColor,
            disabledForegroundColor: Colors.grey[600],
            side: BorderSide(
              color: isEnabled 
                ? (backgroundColor ?? colors.backgroundColor ?? theme.primaryColor)
                : Colors.grey[300]!,
              width: 1.5,
            ),
            padding: EdgeInsets.all(sizeProps.verticalPadding),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            minimumSize: Size(
              sizeProps.iconSize + (sizeProps.verticalPadding * 2),
              sizeProps.iconSize + (sizeProps.verticalPadding * 2),
            ),
          ),
          child: iconWidget,
        );
        break;

      case ButtonType.text:
        button = IconButton(
          onPressed: isEnabled ? onPressed : null,
          icon: iconWidget,
          color: iconColor ?? colors.backgroundColor,
          disabledColor: Colors.grey[600],
          iconSize: sizeProps.iconSize,
          padding: EdgeInsets.all(sizeProps.verticalPadding),
        );
        break;
    }

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }

  _ButtonColors _getButtonColors(BuildContext context) {
    final theme = Theme.of(context);
    
    switch (type) {
      case ButtonType.primary:
        return _ButtonColors(
          backgroundColor: theme.primaryColor,
          textColor: Colors.white,
        );
      case ButtonType.secondary:
        return _ButtonColors(
          backgroundColor: theme.colorScheme.secondary,
          textColor: theme.colorScheme.onSecondary,
        );
      case ButtonType.danger:
        return _ButtonColors(
          backgroundColor: theme.colorScheme.error,
          textColor: Colors.white,
        );
      case ButtonType.outline:
      case ButtonType.text:
        return _ButtonColors(
          backgroundColor: theme.primaryColor,
          textColor: theme.primaryColor,
        );
    }
  }

  _ButtonSizeProperties _getButtonSizeProperties() {
    switch (size) {
      case ButtonSize.small:
        return const _ButtonSizeProperties(
          horizontalPadding: AppSpacing.sm,
          verticalPadding: AppSpacing.sm,
          fontSize: AppTextStyles.bodySmall,
          iconSize: 16,
        );
      case ButtonSize.medium:
        return const _ButtonSizeProperties(
          horizontalPadding: AppSpacing.md,
          verticalPadding: AppSpacing.md,
          fontSize: AppTextStyles.bodyLarge,
          iconSize: 20,
        );
      case ButtonSize.large:
        return const _ButtonSizeProperties(
          horizontalPadding: AppSpacing.lg,
          verticalPadding: AppSpacing.lg,
          fontSize: AppTextStyles.titleMedium,
          iconSize: 24,
        );
    }
  }
}


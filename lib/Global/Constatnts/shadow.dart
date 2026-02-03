import '../../index/index_main.dart';

final shadow_all_events = BoxShadow(
  color: ColorResources.COLOR_GREY90.withValues(alpha: 0.3),
// Slight opacity for smooth shadow
  spreadRadius: 1,
// Expands the shadow
  blurRadius: 1,
// Softens the shadow
  offset: const Offset(0, 5), // Moves the shadow slightly downwards
);

final shadow_booking = BoxShadow(
  color: ColorResources.COLOR_GREY70.withValues(alpha: 0.3),
// Slight opacity for smooth shadow
  spreadRadius: 5,
// Expands the shadow
  blurRadius: 10,
// Softens the shadow
  offset: const Offset(0, 10), // Moves the shadow slightly downwards
);
final shadow_home_events = BoxShadow(
  color: ColorResources.COLOR_GREY50.withValues(alpha: 0.3),
  // Slight opacity for smooth shadow
  spreadRadius: 2,
  // Expands the shadow
  blurRadius: 1,
  // Softens the shadow
  offset: const Offset(0, 3), // Moves the shadow slightly downwards
);

final shadow_explore = BoxShadow(
  color: ColorResources.COLOR_GREY70.withValues(alpha: 0.3),
// Slight opacity for smooth shadow
  spreadRadius: 5,
// Expands the shadow
  blurRadius: 10,
// Softens the shadow
  offset: const Offset(0, 2), // Moves the shadow slightly downwards
);

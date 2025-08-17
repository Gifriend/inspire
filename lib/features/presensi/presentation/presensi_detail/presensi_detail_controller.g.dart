// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presensi_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$presensiDetailControllerHash() =>
    r'6c5c9acfb0adc822ee63abc8ffa71e5d6d8c6ed1';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$PresensiDetailController
    extends BuildlessAutoDisposeNotifier<PresensiDetailState> {
  late final PresensiType activityType;

  PresensiDetailState build(PresensiType activityType);
}

/// See also [PresensiDetailController].
@ProviderFor(PresensiDetailController)
const presensiDetailControllerProvider = PresensiDetailControllerFamily();

/// See also [PresensiDetailController].
class PresensiDetailControllerFamily extends Family<PresensiDetailState> {
  /// See also [PresensiDetailController].
  const PresensiDetailControllerFamily();

  /// See also [PresensiDetailController].
  PresensiDetailControllerProvider call(PresensiType activityType) {
    return PresensiDetailControllerProvider(activityType);
  }

  @override
  PresensiDetailControllerProvider getProviderOverride(
    covariant PresensiDetailControllerProvider provider,
  ) {
    return call(provider.activityType);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'presensiDetailControllerProvider';
}

/// See also [PresensiDetailController].
class PresensiDetailControllerProvider
    extends
        AutoDisposeNotifierProviderImpl<
          PresensiDetailController,
          PresensiDetailState
        > {
  /// See also [PresensiDetailController].
  PresensiDetailControllerProvider(PresensiType activityType)
    : this._internal(
        () => PresensiDetailController()..activityType = activityType,
        from: presensiDetailControllerProvider,
        name: r'presensiDetailControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$presensiDetailControllerHash,
        dependencies: PresensiDetailControllerFamily._dependencies,
        allTransitiveDependencies:
            PresensiDetailControllerFamily._allTransitiveDependencies,
        activityType: activityType,
      );

  PresensiDetailControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.activityType,
  }) : super.internal();

  final PresensiType activityType;

  @override
  PresensiDetailState runNotifierBuild(
    covariant PresensiDetailController notifier,
  ) {
    return notifier.build(activityType);
  }

  @override
  Override overrideWith(PresensiDetailController Function() create) {
    return ProviderOverride(
      origin: this,
      override: PresensiDetailControllerProvider._internal(
        () => create()..activityType = activityType,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        activityType: activityType,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<
    PresensiDetailController,
    PresensiDetailState
  >
  createElement() {
    return _PresensiDetailControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PresensiDetailControllerProvider &&
        other.activityType == activityType;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, activityType.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PresensiDetailControllerRef
    on AutoDisposeNotifierProviderRef<PresensiDetailState> {
  /// The parameter `activityType` of this provider.
  PresensiType get activityType;
}

class _PresensiDetailControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          PresensiDetailController,
          PresensiDetailState
        >
    with PresensiDetailControllerRef {
  _PresensiDetailControllerProviderElement(super.provider);

  @override
  PresensiType get activityType =>
      (origin as PresensiDetailControllerProvider).activityType;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

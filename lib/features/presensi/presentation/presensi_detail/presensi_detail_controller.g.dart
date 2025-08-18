// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presensi_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$presensiDetailControllerHash() =>
    r'638a908a059d00478ea558668f10d9ee642252e3';

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
  late final PresensiType presensiType;

  PresensiDetailState build(PresensiType presensiType);
}

/// See also [PresensiDetailController].
@ProviderFor(PresensiDetailController)
const presensiDetailControllerProvider = PresensiDetailControllerFamily();

/// See also [PresensiDetailController].
class PresensiDetailControllerFamily extends Family<PresensiDetailState> {
  /// See also [PresensiDetailController].
  const PresensiDetailControllerFamily();

  /// See also [PresensiDetailController].
  PresensiDetailControllerProvider call(PresensiType presensiType) {
    return PresensiDetailControllerProvider(presensiType);
  }

  @override
  PresensiDetailControllerProvider getProviderOverride(
    covariant PresensiDetailControllerProvider provider,
  ) {
    return call(provider.presensiType);
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
  PresensiDetailControllerProvider(PresensiType presensiType)
    : this._internal(
        () => PresensiDetailController()..presensiType = presensiType,
        from: presensiDetailControllerProvider,
        name: r'presensiDetailControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$presensiDetailControllerHash,
        dependencies: PresensiDetailControllerFamily._dependencies,
        allTransitiveDependencies:
            PresensiDetailControllerFamily._allTransitiveDependencies,
        presensiType: presensiType,
      );

  PresensiDetailControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.presensiType,
  }) : super.internal();

  final PresensiType presensiType;

  @override
  PresensiDetailState runNotifierBuild(
    covariant PresensiDetailController notifier,
  ) {
    return notifier.build(presensiType);
  }

  @override
  Override overrideWith(PresensiDetailController Function() create) {
    return ProviderOverride(
      origin: this,
      override: PresensiDetailControllerProvider._internal(
        () => create()..presensiType = presensiType,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        presensiType: presensiType,
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
        other.presensiType == presensiType;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, presensiType.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PresensiDetailControllerRef
    on AutoDisposeNotifierProviderRef<PresensiDetailState> {
  /// The parameter `presensiType` of this provider.
  PresensiType get presensiType;
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
  PresensiType get presensiType =>
      (origin as PresensiDetailControllerProvider).presensiType;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

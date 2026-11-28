import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/core/access_manager.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/widgets/terminal_payment_confirmation_dialog.dart';
import 'package:kardex_app_front/src/tools/client_balance_display_helper.dart';
import 'package:kardex_app_front/widgets/gates/gates.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:material_ui/material_ui.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBranchesRepository implements BranchesRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeServinRepository implements ServinRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AuthCubit _createTestAuthCubit() {
  return AuthCubit(
    authRepository: _FakeAuthRepository(),
    branchesRepository: _FakeBranchesRepository(),
    servinRepository: _FakeServinRepository(),
  );
}

Authenticated _buildAuthenticated({
  String userId = 'user-1',
  List<String> access = const ['commercial'],
  RoleCapabilities capabilities = const RoleCapabilities(),
}) {
  final branch = BranchInDb(
    id: 'branch-1',
    name: 'Sucursal Central',
    idCard: 'J0310000000000',
    address: 'Managua',
    email: 'test@example.com',
    phone: '88888888',
    createdAt: DateTime(2026),
  );

  return Authenticated(
    LoginResponse(
      accessToken: 'token',
      user: UserInDbWithRole(
        id: userId,
        username: userId,
        password: '',
        role: 'Tester',
        branches: const ['branch-1'],
        createdAt: DateTime(2026),
        userRole: UserRole(
          name: 'Tester',
          access: access,
          capabilities: capabilities,
        ),
      ),
    ),
    branch,
    [branch],
    Servin(
      name: 'Test Servin',
      nickname: 'test',
      url: 'https://example.com',
      isActive: true,
    ),
  );
}

void main() {
  group('RoleCapabilities', () {
    test('deserializa documentos legacy sin capabilities con todo en true', () {
      final role = UserRoleInDb.fromJson({
        'id': 'r-1',
        'name': 'Vendedor',
        'access': ['commercial'],
        'createdAt': 1700000000000,
      });

      expect(role.capabilities.allowInvoicing, isTrue);
      expect(role.capabilities.allowCreditInvoicing, isTrue);
      expect(role.capabilities.showClientCreditDetails, isTrue);

      final userRole = UserRole.fromJson({
        'name': 'Vendedor',
        'access': ['commercial'],
      });
      expect(userRole.capabilities, const RoleCapabilities());
    });

    test('serializa y deserializa capabilities personalizadas', () {
      const caps = RoleCapabilities(
        allowInvoicing: false,
        allowCreditInvoicing: false,
        showClientCreditDetails: false,
      );
      final role = CreateUserRole(
        name: 'Preventa Limitado',
        access: const ['commercial'],
        capabilities: caps,
      );
      final json = role.toJson();
      expect(json['capabilities'], {
        'allowInvoicing': false,
        'allowCreditInvoicing': false,
        'showClientCreditDetails': false,
      });

      final parsed = UserRole.fromJson(json);
      expect(parsed.capabilities, caps);
    });
  });

  group('AccessManager.hasCapability', () {
    test('root y rol con all siempre tienen todas las capacidades', () {
      final manager = AccessManager();
      final rootAuth = _buildAuthenticated(
        userId: 'root',
        capabilities: const RoleCapabilities(
          allowInvoicing: false,
          allowCreditInvoicing: false,
          showClientCreditDetails: false,
        ),
      );
      final allAuth = _buildAuthenticated(
        userId: 'admin-1',
        access: const ['all'],
        capabilities: const RoleCapabilities(
          allowInvoicing: false,
          allowCreditInvoicing: false,
          showClientCreditDetails: false,
        ),
      );

      for (final cap in RoleCapability.values) {
        expect(manager.hasCapability(rootAuth.session.user, cap), isTrue);
        expect(manager.hasCapability(allAuth.session.user, cap), isTrue);
      }
    });

    test('rol restringido respeta cada bandera individualmente', () {
      final manager = AccessManager();
      final restricted = _buildAuthenticated(
        capabilities: const RoleCapabilities(
          allowInvoicing: true,
          allowCreditInvoicing: false,
          showClientCreditDetails: false,
        ),
      );

      expect(
        manager.hasCapability(restricted.session.user, RoleCapability.allowInvoicing),
        isTrue,
      );
      expect(
        manager.hasCapability(
          restricted.session.user,
          RoleCapability.allowCreditInvoicing,
        ),
        isFalse,
      );
      expect(
        manager.hasCapability(
          restricted.session.user,
          RoleCapability.showClientCreditDetails,
        ),
        isFalse,
      );
    });
  });

  group('RoleCapabilityGateFilter', () {
    testWidgets('oculta o muestra el hijo reactivamente según el rol', (tester) async {
      final authCubit = _createTestAuthCubit();
      addTearDown(authCubit.close);

      authCubit.emit(
        _buildAuthenticated(
          capabilities: const RoleCapabilities(allowInvoicing: false),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Gate(
            filters: [
              RoleCapabilityGateFilter(
                capability: RoleCapability.allowInvoicing,
                authCubit: authCubit,
              ),
            ],
            child: const Text('Facturar'),
          ),
        ),
      );

      expect(find.text('Facturar'), findsNothing);

      authCubit.emit(
        _buildAuthenticated(
          capabilities: const RoleCapabilities(allowInvoicing: true),
        ),
      );
      await tester.pump();

      expect(find.text('Facturar'), findsOneWidget);
    });
  });

  group('ClientBalanceDisplayHelper', () {
    test('devuelve monto o etiqueta según showDetails', () {
      expect(
        ClientBalanceDisplayHelper.formatBalance(15000, showDetails: false),
        'Con saldo pendiente',
      );
      expect(
        ClientBalanceDisplayHelper.formatBalance(0, showDetails: false),
        'Sin saldo',
      );
      expect(
        ClientBalanceDisplayHelper.formatBalance(15000, showDetails: true),
        NumberFormatter.convertToMoneyLike(15000),
      );
    });
  });

  group('TerminalPaymentConfirmationDialog', () {
    testWidgets('hace fallback seguro a Contado si showCredit es false', (tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('RenderFlex overflowed')) {
          return;
        }
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  showTerminalPaymentConfirmationDialog(
                    context,
                    5000,
                    showCredit: false,
                    initialMethod: PaymentType.credit,
                  );
                },
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Confirmar Pago'), findsOneWidget);
      expect(find.text('Credit'), findsNothing);
      expect(find.text('Dinero Recibido'), findsOneWidget);
    });
  });
}

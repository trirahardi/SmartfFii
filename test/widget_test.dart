import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/currency_formatter.dart';
import 'package:mobile/core/utils/validators.dart';
import 'package:mobile/features/transactions/services/smart_input_parser.dart';
import 'package:mobile/data/models/category_model.dart';
import 'package:mobile/shared/widgets/neo_badge.dart';

void main() {
  group('SmartFi Unit & Widget Tests', () {
    test('CurrencyFormatter memformat Rupiah dengan pemisah ribuan titik', () {
      expect(CurrencyFormatter.formatRupiah(1000000), 'Rp 1.000.000');
      expect(CurrencyFormatter.formatRupiah(25000), 'Rp 25.000');
      expect(CurrencyFormatter.formatRupiah(0), 'Rp 0');
    });

    test('Validators memvalidasi email dan kata sandi dengan benar', () {
      expect(Validators.validateEmail('user@smartfi.com'), isNull);
      expect(Validators.validateEmail('bukan-email'), isNotNull);
      expect(Validators.validatePassword('123456'), isNull);
      expect(Validators.validatePassword('123'), isNotNull);
    });

    test(
      'SmartInputParser membedakan pemasukan dan pengeluaran bahasa Indonesia',
      () {
        final categories = CategoryModel.defaultCategories;
        final parseExpense = SmartInputParser.parse(
          'Makan siang padang 25 ribu',
          categories,
        );
        expect(parseExpense.type, 'expense');
        expect(parseExpense.nominal, 25000);

        final parseIncome = SmartInputParser.parse(
          'Gaji bulanan kantor 5 juta',
          categories,
        );
        expect(parseIncome.type, 'income');
        expect(parseIncome.nominal, 5000000);
      },
    );

    testWidgets('NeoBadge me-render teks dengan format Neobrutalism', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: NeoBadge(text: 'SELESAI'),
          ),
        ),
      );

      expect(find.text('SELESAI'), findsOneWidget);
    });
  });
}

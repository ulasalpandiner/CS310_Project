import 'package:campus_market/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void setPhoneSize(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> logIn(WidgetTester tester) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), 'student@sabanciuniv.edu');
  await tester.enterText(fields.at(1), 'sample password');
  await tap(tester, find.text('Log in'));
}

Finder dialogButton(String label) {
  return find.descendant(
    of: find.byType(AlertDialog),
    matching: find.text(label),
  );
}

Future<void> fillField(WidgetTester tester, String label, String value) async {
  final field = find.widgetWithText(TextFormField, label);
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pumpAndSettle();
}

Future<void> chooseOption(
  WidgetTester tester,
  String fieldLabel,
  String option,
) async {
  await tap(
    tester,
    find.widgetWithText(DropdownButtonFormField<String>, fieldLabel),
  );
  await tap(tester, find.text(option).last);
}

void main() {
  for (final size in [const Size(320, 568), const Size(430, 932)]) {
    testWidgets('UI-only login at ${size.width} × ${size.height}', (
      tester,
    ) async {
      setPhoneSize(tester, size);
      await tester.pumpWidget(const CampusMarketApp());

      await tester.enterText(
        find.byType(TextFormField).first,
        'demo@example.com',
      );
      await tap(tester, find.text('Log in'));
      expect(
        find.text('Use a @sabanciuniv.edu email address.'),
        findsOneWidget,
      );
      expect(find.text('Enter a password.'), findsOneWidget);

      await logIn(tester);
      expect(find.text('Search listings & filters'), findsOneWidget);
      expect(find.text('My listings'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('listing form validates fields and requires confirmation', (
    tester,
  ) async {
    setPhoneSize(tester, const Size(320, 568));
    await tester.pumpWidget(const CampusMarketApp());
    await logIn(tester);
    await tap(tester, find.text('+ Sell'));

    await fillField(tester, 'Price (TRY) *', '-20');
    await tap(tester, find.text('Publish listing'));
    expect(find.text('Enter a title.'), findsOneWidget);
    expect(find.text('Enter a price greater than 0.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    await tap(tester, find.text('Add photo'));
    await tap(tester, find.text('Textbook'));
    await fillField(tester, 'Title *', 'Campus test book');
    await fillField(tester, 'Price (TRY) *', '175');
    await fillField(tester, 'Description *', 'Bring it to the library.');
    await chooseOption(tester, 'Category *', 'Textbooks');
    await chooseOption(tester, 'Condition *', 'Good');

    await tap(tester, find.text('Publish listing'));
    expect(find.text('Publish this listing?'), findsOneWidget);
    await tap(tester, dialogButton('Cancel'));
    expect(find.text('Campus test book'), findsOneWidget);

    await tap(tester, find.text('Publish listing'));
    await tap(tester, dialogButton('Publish'));
    expect(find.text('Campus test book'), findsOneWidget);
    expect(find.text('Publish listing'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sold listings leave the feed and owners can remove them', (
    tester,
  ) async {
    setPhoneSize(tester, const Size(430, 932));
    await tester.pumpWidget(const CampusMarketApp());
    await logIn(tester);
    await tester.scrollUntilVisible(
      find.text('Desk lamp'),
      140,
      scrollable: find
          .descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('Desk lamp'), findsOneWidget);

    await tap(tester, find.text('My listings'));
    await tap(tester, find.text('Desk lamp'));
    await tap(tester, find.text('Mark as sold'));
    expect(find.text('Mark as sold?'), findsOneWidget);
    await tap(tester, dialogButton('Mark sold'));
    expect(find.text('SOLD'), findsOneWidget);
    expect(find.text('Mark as sold'), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Desk lamp'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Dorm items'),
      -140,
      scrollable: find
          .descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tap(tester, find.text('Dorm items'));
    expect(find.text('No active listings in Dorm items.'), findsOneWidget);
    expect(find.text('Desk lamp'), findsNothing);

    await tap(tester, find.text('My listings'));
    await tap(tester, find.text('Desk lamp'));
    await tap(tester, find.text('Delete'));
    expect(find.text('Delete this listing?'), findsOneWidget);
    await tap(tester, dialogButton('Delete'));
    expect(find.text('Desk lamp'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

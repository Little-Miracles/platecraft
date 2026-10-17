import 'package:flutter_test/flutter_test.dart';
import 'package:platecraft/translation.dart';
import 'package:platecraft/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('weekdays: the whole week is translated as one phrase', () async {
    SharedPreferences.setMockInitialValues({});
    final tr = TranslationService.instance;
    await tr.load();
    expect(weekdayShort(5), 'Fr');
    tr.fake = (text, from, to) async => 'Пн Вт Ср Чт Пт Сб Нд';
    await tr.setLang('uk');
    await tr.translate('Mon Tue Wed Thu Fri Sat Sun');
    expect(weekdayShort(5), 'Пт');
    expect(weekdayShort(6), 'Сб');
    tr.fake = (text, from, to) async => 'Mo. Di. Mi. Do. Fr. Sa. So';
    await tr.setLang('de');
    await tr.translate('Mon Tue Wed Thu Fri Sat Sun');
    expect(weekdayShort(3), 'Mi');
    await tr.setLang('en');
    tr.fake = null;
  });
}

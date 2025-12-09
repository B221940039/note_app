import 'dart:convert';
import 'package:assigmentv4/database/database_helper.dart';

class SampleDataGenerator {
  static Future<void> generateSampleNotes() async {
    final db = DatabaseHelper.instance;

    // Clear existing data first
    await db.clearAllData();

    final now = DateTime.now();

    final sampleNotes = [
      {
        'title': 'Өглөөний зорилтууд',
        'content':
            'Өнөөдөр хийх зүйлс:\n- Спортоор хичээллэх\n- Ном унших\n- Зураг зурах',
        'tag': 'Personal',
        'color': 0xFFE57373,
        'dateCreated': now.subtract(const Duration(days: 1)).toIso8601String(),
        'audioPath': null,
        'videoPath': null,
        'todoItems': jsonEncode([
          {'title': 'Өглөөний гүйлт хийх', 'value': false},
          {'title': '30 минут ном унших', 'value': false},
        ]),
      },
      {
        'title': 'Ажлын уулзалт',
        'content':
            'Маргааш 10:00 цагт багийн уулзалт. Төслийн явцын тайлан бэлтгэх шаардлагатай.',
        'tag': 'Work',
        'color': 0xFF64B5F6,
        'dateCreated': now.subtract(const Duration(days: 2)).toIso8601String(),
        'audioPath': null,
        'videoPath': null,
        'todoItems': jsonEncode([
          {'title': 'Тайлан бэлтгэх', 'value': false},
          {'title': 'Слайд хийх', 'value': true},
        ]),
      },
      {
        'title': 'Хоолны жор',
        'content':
            'Цуйван хийх жор:\n- Гурил 300г\n- Махан 200г\n- Ногоо\n- Төмс',
        'tag': 'Cooking',
        'color': 0xFF81C784,
        'dateCreated': now.subtract(const Duration(days: 3)).toIso8601String(),
        'audioPath': null,
        'videoPath': null,
        'todoItems': jsonEncode([]),
      },
      {
        'title': 'Аялалын төлөвлөгөө',
        'content':
            'Зуны амралтаар очих газрууд:\n1. Тэрэлж\n2. Хөвсгөл\n3. Алтай',
        'tag': 'Travel',
        'color': 0xFFFFD54F,
        'dateCreated': now.subtract(const Duration(days: 4)).toIso8601String(),
        'audioPath': null,
        'videoPath': null,
        'todoItems': jsonEncode([
          {'title': 'Зочид буудал захиалах', 'value': false},
          {'title': 'Тээврийн хэрэгсэл шалгах', 'value': false},
        ]),
      },
      {
        'title': 'Номын жагсаалт',
        'content':
            'Унших хүсэлтэй номууд:\n- "1984" - Жорж Орвелл\n- "Гэгээн түүх" - Б.Ринчен\n- "Философийн үндэс" - Платон',
        'tag': 'Books',
        'color': 0xFFBA68C8,
        'dateCreated': now.subtract(const Duration(days: 5)).toIso8601String(),
        'audioPath': null,
        'videoPath': null,
        'todoItems': jsonEncode([]),
      },
      {
        'title': 'Санхүүгийн төлөвлөгөө',
        'content':
            'Сарын зардал:\n- Түрээс: 500,000₮\n- Хоол: 300,000₮\n- Тээвэр: 100,000₮\n- Бусад: 200,000₮',
        'tag': 'Finance',
        'color': 0xFF4DB6AC,
        'dateCreated': now.subtract(const Duration(days: 6)).toIso8601String(),
        'audioPath': null,
        'videoPath': null,
        'todoItems': jsonEncode([
          {'title': 'Төсөв гаргах', 'value': true},
          {'title': 'Зардлын дансыг шалгах', 'value': false},
        ]),
      },
      {
        'title': 'Фитнесс хөтөлбөр',
        'content':
            'Долоо хоногийн дасгалууд:\n- Даваа: Цээж, гуя\n- Мягмар: Нуруу, бицепс\n- Лхагва: Амрах\n- Пүрэв: Мөр, трицепс\n- Баасан: Хөл\n- Бямба: Кардио\n- Ням: Амрах',
        'tag': 'Health',
        'color': 0xFFE57373,
        'dateCreated': now.subtract(const Duration(days: 7)).toIso8601String(),
        'audioPath': null,
        'videoPath': null,
        'todoItems': jsonEncode([
          {'title': 'Даваа гарагийн дасгал хийх', 'value': true},
          {'title': 'Мягмар гарагийн дасгал хийх', 'value': false},
        ]),
      },
      {
        'title': 'Программчлалын сургалт',
        'content':
            'Flutter сурах зам:\n1. Dart хэл эзэмших\n2. Widget-үүдтэй танилцах\n3. State management суралцах\n4. API холбох\n5. Firebase ашиглах',
        'tag': 'Study',
        'color': 0xFF64B5F6,
        'dateCreated': now.subtract(const Duration(days: 8)).toIso8601String(),
        'audioPath': null,
        'videoPath': null,
        'todoItems': jsonEncode([
          {'title': 'Dart үндэс дуусгах', 'value': true},
          {'title': 'Flutter widget tutorial үзэх', 'value': false},
          {'title': 'Төсөл эхлүүлэх', 'value': false},
        ]),
      },
      {
        'title': 'Кино жагсаалт',
        'content':
            'Үзэх хүсэлтэй кинонууд:\n- Interstellar\n- The Shawshank Redemption\n- Inception\n- The Matrix',
        'tag': 'Entertainment',
        'color': 0xFF81C784,
        'dateCreated': now.subtract(const Duration(days: 9)).toIso8601String(),
        'audioPath': null,
        'videoPath': null,
        'todoItems': jsonEncode([]),
      },
      {
        'title': 'Гэрийн засвар',
        'content':
            'Энэ сард хийх засвар:\n- Угаалтуурын хулуу солих\n- Хана будах\n- Гэрлийн чийдэн засварлах',
        'tag': 'Home',
        'color': 0xFFFFD54F,
        'dateCreated': now.subtract(const Duration(days: 10)).toIso8601String(),
        'audioPath': null,
        'videoPath': null,
        'todoItems': jsonEncode([
          {'title': 'Сантехникч дуудах', 'value': false},
          {'title': 'Будаг худалдаж авах', 'value': false},
        ]),
      },
      {
        'title': 'Бизнес санаа',
        'content':
            'Startup санаанууд:\n- Хүнсний хүргэлтийн апп\n- Онлайн сургалтын платформ\n- Эко найрсаг бүтээгдэхүүн',
        'tag': 'Business',
        'color': 0xFFBA68C8,
        'dateCreated': now.subtract(const Duration(days: 11)).toIso8601String(),
        'audioPath': null,
        'videoPath': null,
        'todoItems': jsonEncode([
          {'title': 'Зах зээлийн судалгаа хийх', 'value': false},
          {'title': 'Бизнес төлөвлөгөө бичих', 'value': false},
        ]),
      },
      {
        'title': 'Амралтын өдөр',
        'content':
            'Найзуудтайгаа хийх зүйлс:\n- Кафед очих\n- Кино үзэх\n- Паркт алхах',
        'tag': 'Personal',
        'color': 0xFF4DB6AC,
        'dateCreated': now.subtract(const Duration(days: 12)).toIso8601String(),
        'audioPath': null,
        'videoPath': null,
        'todoItems': jsonEncode([]),
      },
      {
        'title': 'Хэл сурах',
        'content':
            'Англи хэл сурах төлөвлөгөө:\n- Өдөр бүр 30 минут унших\n- Duolingo апп ашиглах\n- Podcast сонсох\n- YouTube video үзэх',
        'tag': 'Study',
        'color': 0xFFE57373,
        'dateCreated': now.subtract(const Duration(days: 13)).toIso8601String(),
        'audioPath': null,
        'videoPath': null,
        'todoItems': jsonEncode([
          {'title': 'Duolingo lesson хийх', 'value': false},
          {'title': 'Grammar үзэх', 'value': false},
        ]),
      },
      {
        'title': 'Гэр бүлийн арга хэмжээ',
        'content':
            'Амралтын өдрөөр гэр бүлтэйгээ:\n- Эцэг эх луу очих\n- Хамт хоол хийх\n- Зураг дарах',
        'tag': 'Family',
        'color': 0xFF64B5F6,
        'dateCreated': now.subtract(const Duration(days: 14)).toIso8601String(),
        'audioPath': null,
        'videoPath': null,
        'todoItems': jsonEncode([
          {'title': 'Бэлэг худалдаж авах', 'value': false},
        ]),
      },
      {
        'title': 'Хувцасны жагсаалт',
        'content':
            'Худалдаж авах хувцас:\n- Өвлийн куртик\n- Гутал\n- Свитер\n- Шарвар',
        'tag': 'Shopping',
        'color': 0xFF81C784,
        'dateCreated': now.subtract(const Duration(days: 15)).toIso8601String(),
        'audioPath': null,
        'videoPath': null,
        'todoItems': jsonEncode([]),
      },
      {
        'title': 'Эрүүл мэндийн үзлэг',
        'content':
            'Хийх шинжилгээнүүд:\n- Ерөнхий үзлэг\n- Цусны шинжилгээ\n- Нүдний үзлэг\n- Шүдний үзлэг',
        'tag': 'Health',
        'color': 0xFFFFD54F,
        'dateCreated': now.subtract(const Duration(days: 16)).toIso8601String(),
        'audioPath': null,
        'videoPath': null,
        'todoItems': jsonEncode([
          {'title': 'Эмнэлэгт цаг авах', 'value': false},
          {'title': 'Даатгалын карт авах', 'value': false},
        ]),
      },
      {
        'title': 'Төслийн санаа',
        'content':
            'Шинэ төсөл:\n- Тэмдэглэлийн апп хийх\n- AI ашиглан функц нэмэх\n- Cloud sync ашиглах\n- Бүх платформд гаргах',
        'tag': 'Work',
        'color': 0xFFBA68C8,
        'dateCreated': now.subtract(const Duration(days: 17)).toIso8601String(),
        'audioPath': null,
        'videoPath': null,
        'todoItems': jsonEncode([
          {'title': 'Дизайн хийх', 'value': true},
          {'title': 'Backend бичих', 'value': false},
          {'title': 'Тест хийх', 'value': false},
        ]),
      },
      {
        'title': 'Сайн дурын ажил',
        'content':
            'Олон нийтийн ажил:\n- Хог цэвэрлэх\n- Мод тарих\n- Хүүхдүүдэд заах\n- Хоол хүргэх',
        'tag': 'Personal',
        'color': 0xFF4DB6AC,
        'dateCreated': now.subtract(const Duration(days: 18)).toIso8601String(),
        'audioPath': null,
        'videoPath': null,
        'todoItems': jsonEncode([
          {'title': 'Сайн дурынхантай холбогдох', 'value': false},
        ]),
      },
      {
        'title': 'Урлагийн төсөл',
        'content':
            'Зурах сэдвүүд:\n- Уулын байгаль\n- Хотын дүр төрх\n- Хүний царай\n- Абстракт',
        'tag': 'Art',
        'color': 0xFFE57373,
        'dateCreated': now.subtract(const Duration(days: 19)).toIso8601String(),
        'audioPath': null,
        'videoPath': null,
        'todoItems': jsonEncode([]),
      },
      {
        'title': 'Өдрийн тэмдэглэл',
        'content':
            'Өнөөдрийн бодол:\nАмьдрал бол аялал юм. Өдөр бүр шинэ зүйл суралцаж, хөгжиж байх нь чухал. Бидний бүх зорилго, мөрөөдөл бүр биелэх боломжтой.',
        'tag': 'Personal',
        'color': 0xFF64B5F6,
        'dateCreated': now.subtract(const Duration(hours: 2)).toIso8601String(),
        'audioPath': null,
        'videoPath': null,
        'todoItems': jsonEncode([
          {'title': 'Медитаци хийх', 'value': false},
          {'title': 'Өглөөний дасгал', 'value': true},
        ]),
      },
    ];

    // Insert all sample notes
    for (var note in sampleNotes) {
      await db.insertNote(note);
    }

    print('✅ Successfully generated 20 sample notes!');
  }
}

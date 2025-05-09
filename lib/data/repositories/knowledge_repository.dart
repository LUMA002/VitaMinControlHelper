import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vita_min_control_helper/data/models/knowledge_item.dart';
import 'package:flutter/material.dart';

final knowledgeRepositoryProvider = Provider<KnowledgeRepository>((ref) {
  return KnowledgeRepository();
});

class KnowledgeRepository {
  // Статичні дані для прикладу
  static List<KnowledgeItem> getMockItems() {
    return [
      KnowledgeItem(
        id: '1',
        title: 'Вітамін D',
        category: 'vitamin',
        description:
            'Вітамін D регулює обмін кальцію і фосфору, необхідний для здоров’я кісток, імунітету, знижує ризик аутоімунних захворювань, підтримує роботу м’язів і серця. Дефіцит особливо поширений у людей, які мало бувають на сонці.',
        recommendedDosage: '600-800 МО (15-20 мкг) на день для дорослих',
        deficiencySymptoms:
            'Остеомаляція, остеопороз, біль у кістках, м’язова слабкість, підвищений ризик переломів, депресія, часті застуди.',
        overdoseSymptoms:
            'Гіперкальціємія, нудота, блювота, втрата апетиту, поліурія, кальциноз тканин, порушення роботи нирок.',
        icon: Icons.wb_sunny_outlined,
        foodSources: [
          'Жирна риба (лосось, скумбрія, сардини)',
          'Яєчні жовтки',
          'Печінка тріски',
          'Збагачене молоко',
          'Гриби',
          'Сонячне світло',
        ],
      ),
      KnowledgeItem(
        id: '2',
        title: 'Вітамін C',
        category: 'vitamin',
        description:
            'Вітамін C (аскорбінова кислота) — потужний антиоксидант, необхідний для синтезу колагену, загоєння ран, імунітету, засвоєння заліза, зниження ризику хронічних захворювань.',
        recommendedDosage: '75 мг (жінки), 90 мг (чоловіки) на день',
        deficiencySymptoms:
            'Цинга (кровоточивість ясен, випадіння зубів), слабкість, втома, часті інфекції, сухість шкіри, повільне загоєння ран.',
        overdoseSymptoms:
            'Діарея, нудота, спазми в животі, підвищений ризик утворення каменів у нирках.',
        icon: Icons.sanitizer_outlined,
        foodSources: [
          'Цитрусові',
          'Ківі',
          'Болгарський перець',
          'Броколі',
          'Полуниця',
          'Шпинат',
          'Чорна смородина',
        ],
      ),
      KnowledgeItem(
        id: '3',
        title: 'Цинк',
        category: 'mineral',
        description:
            'Цинк бере участь у понад 300 ферментативних реакціях, важливий для імунітету, синтезу білків і ДНК, загоєння ран, росту і розвитку, підтримки смаку та нюху.',
        recommendedDosage: '11 мг (чоловіки), 8 мг (жінки) на день',
        deficiencySymptoms:
            'Затримка росту, випадіння волосся, діарея, зниження апетиту, дерматит, зниження імунітету.',
        overdoseSymptoms:
            'Нудота, блювота, біль у животі, зниження імунітету, порушення засвоєння міді.',
        icon: Icons.ac_unit_outlined,
        foodSources: [
          'Устриці',
          'Яловичина',
          'Насіння гарбуза',
          'Кеш’ю',
          'Бобові',
          'Цільнозернові продукти',
        ],
      ),
      KnowledgeItem(
        id: '4',
        title: 'Кальцій',
        category: 'mineral',
        description:
            'Кальцій — основний мінерал кісток і зубів, необхідний для скорочення м’язів, згортання крові, передачі нервових імпульсів, регуляції серцевого ритму.',
        recommendedDosage: '1000-1200 мг на день для дорослих',
        deficiencySymptoms:
            'Остеопороз, остеомаляція, м’язові судоми, оніміння, ламкість нігтів, підвищений ризик переломів.',
        overdoseSymptoms:
            'Гіперкальціємія, камені в нирках, закрепи, порушення серцевого ритму.',
        icon: Icons.fitness_center_outlined,
        foodSources: [
          'Молочні продукти',
          'Сардини з кістками',
          'Капуста',
          'Броколі',
          'Мигдаль',
          'Тофу',
        ],
      ),
      KnowledgeItem(
        id: '5',
        title: 'Вітамін B12 (кобаламін)',
        category: 'vitamin',
        description:
            'Вітамін B12 необхідний для утворення еритроцитів, синтезу ДНК, роботи нервової системи, профілактики анемії. Дефіцит часто у вегетаріанців.',
        recommendedDosage: '2,4 мкг на день для дорослих',
        deficiencySymptoms:
            'Анемія, втома, оніміння, порушення пам’яті, депресія, неврологічні розлади.',
        overdoseSymptoms: 'Відносно безпечний, надлишок виводиться з сечею.',
        icon: Icons.opacity,
        foodSources: [
          'Печінка',
          'Яловичина',
          'Риба',
          'Яйця',
          'Молочні продукти',
        ],
      ),
      KnowledgeItem(
        id: '6',
        title: 'Магній',
        category: 'mineral',
        description:
            'Магній бере участь у понад 300 біохімічних реакціях, важливий для м’язів, нервів, синтезу білків, регуляції тиску, профілактики мігрені.',
        recommendedDosage: '400-420 мг (чоловіки), 310-320 мг (жінки) на день',
        deficiencySymptoms:
            'М’язові судоми, тремор, дратівливість, безсоння, аритмія, підвищений тиск.',
        overdoseSymptoms: 'Діарея, нудота, зниження тиску, м’язова слабкість.',
        icon: Icons.spa_outlined,
        foodSources: [
          'Гарбузове насіння',
          'Мигдаль',
          'Шпинат',
          'Чорний шоколад',
          'Авокадо',
          'Бобові',
        ],
      ),
      KnowledgeItem(
        id: '7',
        title: 'Залізо',
        category: 'mineral',
        description:
            'Залізо — ключовий компонент гемоглобіну, транспортує кисень, важливий для енергії, імунітету, когнітивних функцій. Дефіцит — найпоширеніший у світі.',
        recommendedDosage: '8 мг (чоловіки), 18 мг (жінки) на день',
        deficiencySymptoms:
            'Анемія, втома, блідість, задишка, ламкість нігтів, випадіння волосся.',
        overdoseSymptoms:
            'Нудота, блювота, біль у животі, ураження печінки, небезпечно для дітей.',
        icon: Icons.fitness_center,
        foodSources: [
          'Червоне м’ясо',
          'Печінка',
          'Бобові',
          'Шпинат',
          'Квасоля',
          'Гранат',
        ],
      ),
      KnowledgeItem(
        id: '8',
        title: 'Вітамін E',
        category: 'vitamin',
        description:
            'Вітамін E — антиоксидант, захищає клітини від окисного стресу, підтримує імунітет, здоров’я шкіри та очей, знижує ризик серцево-судинних захворювань.',
        recommendedDosage: '15 мг (22,4 МО) на день для дорослих',
        deficiencySymptoms:
            'М’язова слабкість, порушення координації, проблеми із зором, ослаблення імунітету.',
        overdoseSymptoms: 'Підвищений ризик кровотечі, головний біль, втома.',
        icon: Icons.favorite_border,
        foodSources: [
          'Мигдаль',
          'Соняшникова олія',
          'Авокадо',
          'Шпинат',
          'Горіхи',
        ],
      ),
      // Нові та розширені елементи
      KnowledgeItem(
        id: '9',
        title: 'Вітамін А',
        category: 'vitamin',
        description:
            'Вітамін А (ретинол) необхідний для зору, росту клітин, імунітету, здоров’я шкіри та слизових оболонок. Дефіцит — основна причина сліпоти у дітей у світі.',
        recommendedDosage: '700 мкг (жінки), 900 мкг (чоловіки) на день',
        deficiencySymptoms:
            'Погіршення сутінкового зору, сухість шкіри, часті інфекції, ксерофтальмія.',
        overdoseSymptoms:
            'Головний біль, нудота, біль у суглобах, випадіння волосся, ураження печінки.',
        icon: Icons.visibility,
        foodSources: [
          'Морква',
          'Печінка',
          'Яйця',
          'Молоко',
          'Шпинат',
          'Солодка картопля',
        ],
      ),
      KnowledgeItem(
        id: '10',
        title: 'Вітамін B6 (піридоксин)',
        category: 'vitamin',
        description:
            'Вітамін B6 потрібен для метаболізму білків, роботи мозку, синтезу нейромедіаторів, регуляції гомоцистеїну.',
        recommendedDosage: '1,3-2 мг на день для дорослих',
        deficiencySymptoms:
            'Дратівливість, депресія, анемія, тріщини на губах, дерматит.',
        overdoseSymptoms:
            'Поколювання, оніміння кінцівок, сенсорна невропатія.',
        icon: Icons.psychology,
        foodSources: [
          'Печінка',
          'Риба',
          'Картопля',
          'Банани',
          'Горіхи',
          'Курка',
        ],
      ),
      KnowledgeItem(
        id: '11',
        title: 'Вітамін K',
        category: 'vitamin',
        description:
            'Вітамін K необхідний для згортання крові, синтезу білків кісткової тканини, профілактики остеопорозу.',
        recommendedDosage: '90 мкг (жінки), 120 мкг (чоловіки) на день',
        deficiencySymptoms:
            'Кровотечі, синці, погане загоєння ран, остеопенія.',
        overdoseSymptoms: 'Рідко зустрічається, можливі алергічні реакції.',
        icon: Icons.healing,
        foodSources: ['Броколі', 'Шпинат', 'Капуста', 'Зелень', 'Огірки'],
      ),
      KnowledgeItem(
        id: '12',
        title: 'Селен',
        category: 'mineral',
        description:
            'Селен — антиоксидант, підтримує імунітет, функцію щитоподібної залози, захищає від окисного стресу, важливий для репродуктивного здоров’я.',
        recommendedDosage: '55 мкг на день для дорослих',
        deficiencySymptoms:
            'Слабкість, м’язовий біль, кардіоміопатія, проблеми з імунітетом.',
        overdoseSymptoms:
            'Часниковий запах з рота, випадіння волосся, ламкість нігтів, ураження нервової системи.',
        icon: Icons.shield_moon,
        foodSources: ['Бразильський горіх', 'Морепродукти', 'Яйця', 'М’ясо'],
      ),
      KnowledgeItem(
        id: '13',
        title: 'Калій',
        category: 'mineral',
        description:
            'Калій регулює артеріальний тиск, роботу серця, баланс рідин, скорочення м’язів, знижує ризик інсульту.',
        recommendedDosage: '2500-3500 мг на день для дорослих',
        deficiencySymptoms:
            'М’язова слабкість, судоми, аритмія, підвищений тиск.',
        overdoseSymptoms: 'Порушення серцевого ритму, слабкість, параліч.',
        icon: Icons.bolt,
        foodSources: [
          'Банани',
          'Картопля',
          'Квасоля',
          'Шпинат',
          'Апельсини',
          'Авокадо',
        ],
      ),
      KnowledgeItem(
        id: '14',
        title: 'Фосфор',
        category: 'mineral',
        description:
            'Фосфор — для кісток, зубів, енергетичного обміну, синтезу ДНК, підтримки кислотно-лужного балансу.',
        recommendedDosage: '700 мг на день для дорослих',
        deficiencySymptoms:
            'Слабкість, біль у кістках, втрата апетиту, порушення росту.',
        overdoseSymptoms: 'Порушення балансу кальцію, судоми, кальциноз.',
        icon: Icons.science,
        foodSources: ['М’ясо', 'Молочні продукти', 'Горіхи', 'Риба', 'Яйця'],
      ),
      KnowledgeItem(
        id: '15',
        title: 'Йод',
        category: 'mineral',
        description:
            'Йод необхідний для синтезу гормонів щитоподібної залози, розвитку мозку, регуляції обміну речовин. Дефіцит — основна причина зобу.',
        recommendedDosage: '150 мкг на день для дорослих',
        deficiencySymptoms:
            'Зоб, втома, порушення пам’яті, сухість шкіри, затримка розвитку у дітей.',
        overdoseSymptoms:
            'Порушення функції щитоподібної залози, тиреотоксикоз.',
        icon: Icons.waves,
        foodSources: [
          'Морська капуста',
          'Риба',
          'Морепродукти',
          'Йодована сіль',
        ],
      ),
      KnowledgeItem(
        id: '16',
        title: 'Фолієва кислота (B9)',
        category: 'vitamin',
        description:
            'Фолієва кислота важлива для синтезу ДНК, росту клітин, профілактики вроджених вад, роботи мозку.',
        recommendedDosage: '400 мкг на день для дорослих',
        deficiencySymptoms:
            'Анемія, втома, проблеми з пам’яттю, дефекти нервової трубки у плода.',
        overdoseSymptoms: 'Може маскувати дефіцит B12, алергічні реакції.',
        icon: Icons.grass,
        foodSources: ['Зелень', 'Бобові', 'Апельсини', 'Зернові', 'Шпинат'],
      ),
      KnowledgeItem(
        id: '17',
        title: 'Мідь',
        category: 'mineral',
        description:
            'Мідь бере участь у синтезі колагену, імунітеті, засвоєнні заліза, антиоксидантному захисті.',
        recommendedDosage: '900 мкг на день для дорослих',
        deficiencySymptoms:
            'Анемія, слабкість, проблеми зі шкірою, остеопороз.',
        overdoseSymptoms:
            'Блювота, біль у животі, ураження печінки, неврологічні розлади.',
        icon: Icons.emoji_nature,
        foodSources: ['Горіхи', 'Молюски', 'Какао', 'Печінка', 'Гречка'],
      ),
      KnowledgeItem(
        id: '18',
        title: 'Вітамін B1 (тіамін)',
        category: 'vitamin',
        description:
            'Вітамін B1 необхідний для енергетичного обміну, роботи нервової системи, серця, травлення.',
        recommendedDosage: '1,1-1,2 мг на день для дорослих',
        deficiencySymptoms:
            'Берi-берi (слабкість, втрата апетиту, набряки, порушення серця, неврити).',
        overdoseSymptoms: 'Надлишок не накопичується, токсичність не описана.',
        icon: Icons.flash_on,
        foodSources: ['Цільнозернові', 'Свинина', 'Горох', 'Квасоля', 'Горіхи'],
      ),
      KnowledgeItem(
        id: '19',
        title: 'Вітамін B2 (рибофлавін)',
        category: 'vitamin',
        description:
            'Вітамін B2 важливий для енергетичного обміну, здоров’я шкіри, зору, нервової системи.',
        recommendedDosage: '1,1-1,3 мг на день для дорослих',
        deficiencySymptoms:
            'Тріщини в кутах рота, дерматит, світлобоязнь, анемія.',
        overdoseSymptoms: 'Надлишок не накопичується, токсичність не описана.',
        icon: Icons.light_mode,
        foodSources: ['Молоко', 'Яйця', 'Мигдаль', 'Печінка', 'Шпинат'],
      ),
      KnowledgeItem(
        id: '20',
        title: 'Вітамін B3 (ніацин)',
        category: 'vitamin',
        description:
            'Вітамін B3 потрібен для енергетичного обміну, роботи нервової системи, шкіри, травлення.',
        recommendedDosage: '14-16 мг на день для дорослих',
        deficiencySymptoms: 'Пелагра (дерматит, діарея, деменція), слабкість.',
        overdoseSymptoms:
            'Почервоніння шкіри, свербіж, ураження печінки при великих дозах.',
        icon: Icons.local_fire_department,
        foodSources: ['М’ясо', 'Печінка', 'Риба', 'Горіхи', 'Цільнозернові'],
      ),
      KnowledgeItem(
        id: '21',
        title: 'Вітамін B5 (пантотенова кислота)',
        category: 'vitamin',
        description:
            'Вітамін B5 необхідний для синтезу коферменту А, енергетичного обміну, синтезу гормонів.',
        recommendedDosage: '5 мг на день для дорослих',
        deficiencySymptoms: 'Втома, депресія, парестезії, судоми.',
        overdoseSymptoms: 'Діарея, затримка води при дуже великих дозах.',
        icon: Icons.directions_run,
        foodSources: ['Печінка', 'Яйця', 'Авокадо', 'Броколі', 'Гриби'],
      ),
      KnowledgeItem(
        id: '22',
        title: 'Вітамін B7 (біотин)',
        category: 'vitamin',
        description:
            'Біотин важливий для метаболізму жирів, білків, вуглеводів, здоров’я шкіри, волосся, нігтів.',
        recommendedDosage: '30 мкг на день для дорослих',
        deficiencySymptoms:
            'Висип, випадіння волосся, депресія, втома, м’язовий біль.',
        overdoseSymptoms: 'Токсичність не описана.',
        icon: Icons.face,
        foodSources: ['Яйця', 'Горіхи', 'Соя', 'Цвітна капуста', 'Печінка'],
      ),
      KnowledgeItem(
        id: '23',
        title: 'Вітамін B9 (фолат)',
        category: 'vitamin',
        description:
            'Фолат необхідний для синтезу ДНК, росту клітин, профілактики вроджених вад, роботи мозку.',
        recommendedDosage: '400 мкг на день для дорослих',
        deficiencySymptoms:
            'Анемія, втома, проблеми з пам’яттю, дефекти нервової трубки у плода.',
        overdoseSymptoms: 'Може маскувати дефіцит B12, алергічні реакції.',
        icon: Icons.eco,
        foodSources: ['Зелень', 'Бобові', 'Апельсини', 'Зернові', 'Шпинат'],
      ),
      KnowledgeItem(
        id: '24',
        title: 'Фтор',
        category: 'mineral',
        description:
            'Фтор зміцнює зуби, запобігає карієсу, підтримує мінералізацію кісток.',
        recommendedDosage: '3-4 мг на день для дорослих',
        deficiencySymptoms: 'Карієс, слабкість зубної емалі.',
        overdoseSymptoms: 'Флюороз, плями на зубах, ураження кісток.',
        icon: Icons.tag_faces_rounded,
        foodSources: ['Вода', 'Риба', 'Чай', 'Морепродукти'],
      ),
      KnowledgeItem(
        id: '25',
        title: 'Хром',
        category: 'mineral',
        description:
            'Хром регулює рівень глюкози, важливий для обміну жирів і вуглеводів, чутливості до інсуліну.',
        recommendedDosage: '25-35 мкг на день для дорослих',
        deficiencySymptoms:
            'Порушення толерантності до глюкози, підвищений ризик діабету 2 типу.',
        overdoseSymptoms: 'Порушення роботи нирок, алергічні реакції.',
        icon: Icons.bloodtype,
        foodSources: ['М’ясо', 'Яйця', 'Броколі', 'Горіхи', 'Цільнозернові'],
      ),
      KnowledgeItem(
        id: '26',
        title: 'Марганець',
        category: 'mineral',
        description:
            'Марганець потрібен для кісток, метаболізму, антиоксидантного захисту, синтезу сполучної тканини.',
        recommendedDosage: '1,8-2,3 мг на день для дорослих',
        deficiencySymptoms:
            'Порушення росту, слабкість, проблеми з кістками, порушення метаболізму.',
        overdoseSymptoms:
            'Порушення нервової системи, тремор, порушення пам’яті.',
        icon: Icons.park,
        foodSources: ['Горіхи', 'Чай', 'Зернові', 'Шпинат', 'Ананас'],
      ),
      KnowledgeItem(
        id: '27',
        title: 'Молібден',
        category: 'mineral',
        description:
            'Молібден — кофактор багатьох ферментів, важливий для метаболізму сірковмісних амінокислот.',
        recommendedDosage: '45 мкг на день для дорослих',
        deficiencySymptoms:
            'Дуже рідко: порушення обміну сірки, неврологічні симптоми.',
        overdoseSymptoms: 'Підвищення сечової кислоти, подагра.',
        icon: Icons.precision_manufacturing,
        foodSources: ['Бобові', 'Зернові', 'Горіхи', 'Молоко'],
      ),
      KnowledgeItem(
        id: '28',
        title: 'Кобальт',
        category: 'mineral',
        description:
            'Кобальт входить до складу вітаміну B12, важливий для кровотворення, нервової системи.',
        recommendedDosage: 'Немає окремої норми, входить до складу B12',
        deficiencySymptoms:
            'Анемія, неврологічні порушення (як при дефіциті B12).',
        overdoseSymptoms:
            'Порушення роботи щитоподібної залози, кардіоміопатія.',
        icon: Icons.cable,
        foodSources: ['Печінка', 'М’ясо', 'Молочні продукти', 'Молюски'],
      ),
      KnowledgeItem(
        id: '29',
        title: 'Сірка',
        category: 'mineral',
        description:
            'Сірка входить до складу амінокислот, вітамінів, ферментів, важлива для шкіри, волосся, суглобів.',
        recommendedDosage: 'Немає окремої норми, надходить з білками',
        deficiencySymptoms:
            'Вкрай рідко: ламкість волосся, нігтів, сухість шкіри.',
        overdoseSymptoms: 'Діарея при надлишку сульфатів.',
        icon: Icons.cloud,
        foodSources: ['М’ясо', 'Яйця', 'Молочні продукти', 'Бобові', 'Часник'],
      ),
      KnowledgeItem(
        id: '30',
        title: 'Хлор',
        category: 'mineral',
        description:
            'Хлор — основний аніон позаклітинної рідини, важливий для балансу електролітів, травлення (шлунковий сік).',
        recommendedDosage: '2,3 г на день для дорослих',
        deficiencySymptoms: 'М’язова слабкість, порушення травлення, судоми.',
        overdoseSymptoms: 'Гіпертонія, затримка рідини.',
        icon: Icons.water,
        foodSources: ['Сіль', 'Овочі', 'Морепродукти', 'М’ясо'],
      ),
    ];
  }
}

Утилита для подсчета количества email по каждому домену

    perl parser.pl -file list.txt

Входные данные:
Текстовый файл с email-адресами (разделитель — перевод строки). Пример:

    info@mail.ru
    support@vk.com
    ddd@rambler.ru
    roxette@mail.ru
    sdfsdf@@@@@rdfdf
    example@localhost
    иван@иванов.рф
    ivan@xn--c1ad6a.xn--p1ai

С проверкой валидности email-адреса. Если адрес не валиден, тогда данные группируются по ключу INVALID

Punycode декодируется в *.рф

Формат выходных данных (данные сортируются по количеству адресов в домене в порядке убывания):

    INVALID 3
    mail.ru 2
    vk.com  1
    rambler.ru  1
    рег.рф 1

- ./app - приложение
- ./app/lib - необходимые библиотеки, которые написаны конкретно для этой задачи
- ./app/parser.pl - утилита для командной строки
- ./app/list.txt - файл с входными данными

Для вызова утилиты использовать 

    >perl parser.pl -file list.txt

- ./module_tests - набор тестов
- ./module_tests/main.sh - скрипт для запуска тестов
- ./module_tests/t - сами тесты
- ./module_tests/t/1_modules.t - тест на некоторые модули с CPAN, которые используются в библиотеках

Остальные тесты соответствуют по названию тестируемым библиотекам из директории lib

Для запуска всех тестов (из module_tests)

    >sh main.sh

Для запуска тестов по одному (из module_tests/t)

    >perl 1_modules.t

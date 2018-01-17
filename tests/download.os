#Использовать asserts
#Использовать fs
#Использовать tempfiles


#Использовать "../src/core"
#Использовать "../src/cmd"

Перем Лог;

Перем юТест;
Перем мВременныеФайлы;
Перем Проц;
Перем КаталогСборки;

Функция ПолучитьСписокТестов(Знач Тестирование) Экспорт
	
	юТест = Тестирование;
	
	ИменаТестов = Новый Массив;
	СИ = Новый СистемнаяИнформация();
	Если НЕ (Найти(СИ.ВерсияОС, "Windows") > 0) Тогда
		ИменаТестов.Добавить("ТестДолжен_СкачатьПакетыСЛокальногоХранилища");
	КонецЕсли;
	
	Возврат ИменаТестов;

КонецФункции

Процедура ПередЗапускомТеста() Экспорт
	КаталогСборки = юТест.ИмяВременногоФайла();
	СоздатьКаталог(КаталогСборки);
	СтрокаЗапуска = "python3 -m http.server";
	Проц = СоздатьПроцесс(СтрокаЗапуска, КаталогСборки);
	Проц.Запустить();
	Приостановить(1000)
КонецПроцедуры

Процедура ПослеЗапускаТеста() Экспорт
	//мВременныеФайлы.Удалить();
	ПутьККаталогу = ОбъединитьПути(ТекущийКаталог(), "oscript_modules", "test");
	Если ФС.КаталогСуществует(ПутьККаталогу) Тогда
		УдалитьФайлы(ПутьККаталогу);
	КонецЕсли;
	Попытка
		Проц.Завершить();
	Исключение
	КонецПопытки;

КонецПроцедуры

Процедура ТестДолжен_СкачатьПакетыСЛокальногоХранилища() Экспорт

	ФайлНастройки = Новый Файл(ОбъединитьПути(ТекущийСценарий().Каталог, "fixtures", "opm-servers.cfg"));
	
	Сборщик = Новый СборщикПакета;
	КаталогПакета = ОбъединитьПути(ТекущийСценарий().Каталог, "testpackage", "testpackage-0.3.1");
	КопироватьФайл(ФайлНастройки.ПолноеИмя, ОбъединитьПути(КаталогПакета, КонстантыOpm.ИмяФайлаНастроек));

	УстановитьТекущийКаталог(КаталогПакета);
	
	
	Сборщик.СобратьПакет(КаталогПакета, Неопределено, КаталогСборки);
	
	ФайлПакета = Новый Файл(ОбъединитьПути(КаталогСборки, "test-0.3.1.ospx"));
	Утверждения.ПроверитьИстину(ФайлПакета.Существует(), "Файл пакета должен существовать");
	СоздатьКаталог(ОбъединитьПути(КаталогСборки,"test"));
	КопироватьФайл(ФайлПакета.ПолноеИмя, ОбъединитьПути(КаталогСборки,"test/test-0.3.1.ospx"));
	КопироватьФайл(ФайлПакета.ПолноеИмя, ОбъединитьПути(КаталогСборки, "test/test.ospx"));


	Запись = Новый ЗаписьТекста(ОбъединитьПути(КаталогСборки,"list.txt"));
 	Запись.ЗаписатьСтроку("test");
 	Запись.Закрыть();

	ПараметрыПриложенияOpm.НастроитьOpm();

	МенеджерПолучения = Новый МенеджерПолученияПакетов();
	
	Лог.Отладка("Количество доступных пакетов <%1>", МенеджерПолучения.ПолучитьДоступныеПакетов().Количество());
	
	ПакетТестДоступен = МенеджерПолучения.ПакетДоступен("test");

	Утверждения.ПроверитьИстину(ПакетТестДоступен, "Пакета test не существует на внутреннем хабе.");
	
	МенеджерПолучения = Неопределено;

	РаботаСПакетами.УстановитьПакетИзОблака("test", РежимУстановкиПакетов.Локально, Неопределено);

	КэшЛокальный = Новый КэшУстановленныхПакетов;
	Пакеты = КэшЛокальный.ПолучитьУстановленныеПакеты();
	ПутьККаталогу = ОбъединитьПути(ТекущийКаталог(), "oscript_modules", "test");

	Утверждения.ПроверитьИстину(Новый Файл(ПутьККаталогу).Существует(), "Пакет не существует на локальной машине.");
	УдалитьФайлы(ОбъединитьПути(КаталогПакета, КонстантыOpm.ИмяФайлаНастроек));

КонецПроцедуры

Лог = Логирование.ПолучитьЛог("oscript.app.opm");
Лог.УстановитьУровень(УровниЛога.Отладка);
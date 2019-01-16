///////////////////////////////////////////////////////////////////////////////
// 
// Служебный модуль с реализацией сценариев обработки файлов 
//	<ДобавлениеПробеловПередКлючевымиСловами>
//
///////////////////////////////////////////////////////////////////////////////

// ИмяСценария
//	Возвращает имя сценария обработки файлов
//
// Возвращаемое значение:
//   Строка   - Имя текущего сценария обработки файлов
//
Функция ИмяСценария() Экспорт
	
	Возврат "ДобавлениеПробеловПередКлючевымиСловами";

КонецФункции // ИмяСценария()

// ОбработатьФайл
//	Выполняет обработку файла
//
// Параметры:
//  АнализируемыйФайл		- Файл - Файл из журнала git для анализа
//  КаталогИсходныхФайлов  	- Строка - Каталог расположения исходных файлов относительно каталог репозитория
//  ДополнительныеПараметры - Структура - Набор дополнительных параметров, которые можно использовать 
//  	* Лог  					- Объект - Текущий лог
//  	* ИзмененныеКаталоги	- Массив - Каталоги, которые необходимо добавить в индекс
//		* КаталогРепозитория	- Строка - Адрес каталога репозитория
//		* ФайлыДляПостОбработки	- Массив - Файлы, изменившиеся / образоавшиеся в результате работы сценария
//											и которые необходимо дообработать
//
// Возвращаемое значение:
//   Булево   - Признак выполненной обработки файла
//
Функция ОбработатьФайл(АнализируемыйФайл, КаталогИсходныхФайлов, ДополнительныеПараметры) Экспорт
	
	Лог = ДополнительныеПараметры.Лог;
	НастройкиСценария = ДополнительныеПараметры.УправлениеНастройками.Настройка("Precommt4onecСценарии\НастройкиСценариев").Получить(ИмяСценария());
	Если АнализируемыйФайл.Существует() И ТипыФайлов.ЭтоФайлИсходников(АнализируемыйФайл) Тогда
		
		Лог.Информация("Обработка файла '%1' по сценарию '%2'", АнализируемыйФайл.ПолноеИмя, ИмяСценария());
		
		Если ВставитьНужныеПробелы(АнализируемыйФайл.ПолноеИмя) Тогда

			ДополнительныеПараметры.ИзмененныеКаталоги.Добавить(АнализируемыйФайл.ПолноеИмя);

		КонецЕсли;

		Возврат Истина;
		
	КонецЕсли;
	
	Возврат ЛОЖЬ;

КонецФункции // ОбработатьФайл()

Функция ВставитьНужныеПробелы(Знач ИмяФайла)
	
	БылиИзменения = Ложь;

	Текст = Новый ЧтениеТекста();
	Текст.Открыть(ИмяФайла, КодировкаТекста.UTF8NoBOM);
	СодержимоеФайла = Текст.Прочитать();
	Текст.Закрыть();

	Если Не ЗначениеЗаполнено(СодержимоеФайла) Тогда
		
		Возврат БылиИзменения;
		
	КонецЕсли;
	
	Регексп = Новый РегулярноеВыражение("(^[^\n\/]*\))(Экспорт)([\s]*?)([\/\/]+[^\n]*?)*?$");
	Регексп.ИгнорироватьРегистр = ИСТИНА;
	Регексп.Многострочный = ИСТИНА;
	ГруппыИндексов = Регексп.НайтиСовпадения(СодержимоеФайла);
	Если ГруппыИндексов.Количество() > 0 Тогда
	
		СодержимоеФайла = Регексп.Заменить(СодержимоеФайла, "$1 $2$3$4");
	
		ЗаписьТекста = Новый ЗаписьТекста(ИмяФайла, КодировкаТекста.UTF8NoBOM,,, Символы.ПС);
		ЗаписьТекста.Записать(СодержимоеФайла);
		ЗаписьТекста.Закрыть();
		
		БылиИзменения = Истина;

	КонецЕсли;
	
	//Обрамляем все арифметические операции пробелами через regexp.
	//Через CтрЗаменить:
	//	Убираем Двойные пробелы (Внимание осторожно - возможно испортить строковые литералы, используемые например для поиска).
	//	Убираем лишние пробелы перед[ ,);| ] и после [ [); ].
	//	
	Регексп = Новый РегулярноеВыражение("(([#]+[^\n]*?$)|([\|]+[^\n]*?$)|(""[^\n]*"")|(>=)|(<=)|(<>)|>|<|((,)(\S)*?)|[\+\*-]|=|([\/\/]+[^\n]*?))");
	Регексп.ИгнорироватьРегистр = ИСТИНА;
	Регексп.Многострочный = ИСТИНА;
	ГруппыИндексов = Регексп.НайтиСовпадения(СодержимоеФайла);
	Если ГруппыИндексов.Количество() > 0 Тогда
	
		СодержимоеФайла = Регексп.Заменить(СодержимоеФайла, " $1 ");

		Пока СодержимоеФайла <> СтрЗаменить(СодержимоеФайла, "  ", " ") Цикл
			СодержимоеФайла = СтрЗаменить(СодержимоеФайла, "  ", " ");
		КонецЦикла;
		Пока СодержимоеФайла <> СтрЗаменить(СодержимоеФайла, " ,", ",") Цикл
			СодержимоеФайла = СтрЗаменить(СодержимоеФайла, " ,", ",");
		КонецЦикла;
		Пока СодержимоеФайла <> СтрЗаменить(СодержимоеФайла, "( ", "(") Цикл
			СодержимоеФайла = СтрЗаменить(СодержимоеФайла, "( ", "(");
		КонецЦикла;
		Пока СодержимоеФайла <> СтрЗаменить(СодержимоеФайла, " )", ")") Цикл
			СодержимоеФайла = СтрЗаменить(СодержимоеФайла, " )", ")");
		КонецЦикла;
		Пока СодержимоеФайла <> СтрЗаменить(СодержимоеФайла, " ;", ";") Цикл
			СодержимоеФайла = СтрЗаменить(СодержимоеФайла, " ;", ";");
		КонецЦикла;
		
		//заменяем " //" на "//"
		Регексп = Новый РегулярноеВыражение("(^[ ]{0,1}([\/]{1,}))");
		Регексп.ИгнорироватьРегистр = ИСТИНА;
		Регексп.Многострочный = ИСТИНА;
		ГруппыИндексов = Регексп.НайтиСовпадения(СодержимоеФайла);
		Если ГруппыИндексов.Количество() > 0 Тогда
			СодержимоеФайла = Регексп.Заменить(СодержимоеФайла, "$2");
		КонецЕсли;
		
		Пока СодержимоеФайла <> СтрЗаменить(СодержимоеФайла, " #", "#") Цикл
			СодержимоеФайла = СтрЗаменить(СодержимоеФайла, " #", "#");
		КонецЦикла;
		Пока СодержимоеФайла <> СтрЗаменить(СодержимоеФайла, " |", "|") Цикл
			СодержимоеФайла = СтрЗаменить(СодержимоеФайла, " |", "|");
		КонецЦикла;
		Пока СодержимоеФайла <> СтрЗаменить(СодержимоеФайла, "[ ", "[") Цикл
			СодержимоеФайла = СтрЗаменить(СодержимоеФайла, "[ ", "[");
		КонецЦикла;
		Пока СодержимоеФайла <> СтрЗаменить(СодержимоеФайла, " ]", "]") Цикл
			СодержимоеФайла = СтрЗаменить(СодержимоеФайла, " ]", "]");
		КонецЦикла;

		ЗаписьТекста = Новый ЗаписьТекста(ИмяФайла, КодировкаТекста.UTF8NoBOM, , , Символы.ПС);
		ЗаписьТекста.Записать(СодержимоеФайла);
		ЗаписьТекста.Закрыть();
		
		БылиИзменения = Истина;

	КонецЕсли;

	Возврат БылиИзменения;

КонецФункции

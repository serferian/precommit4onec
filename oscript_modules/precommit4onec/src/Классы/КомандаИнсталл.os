///////////////////////////////////////////////////////////////////////////////
//
// Служебный модуль с реализацией работы команды <install>
//
// (с) BIA Technologies, LLC
//
///////////////////////////////////////////////////////////////////////////////

#Использовать gitrunner
Перем Лог;

///////////////////////////////////////////////////////////////////////////////

Процедура НастроитьКоманду(Знач Команда, Знач Парсер) Экспорт

	// Добавление параметров команды
	Парсер.ДобавитьПозиционныйПараметрКоманды(Команда, "КаталогРепозитория", "Каталог репозитория, которому необходимо подключить precommit. При наличии флага -r устанавливает во вложенные в указанных каталог репозитории.");
	Парсер.ДобавитьИменованныйПараметрКоманды(Команда, "-source-dir", "Каталог расположения исходных файлов относительно корня репозитория. По умолчанию <src>");
	Парсер.ДобавитьПараметрФлагКоманды(Команда, "-from-path", "Установить с учетом того, что скрипт прописан в path");
	Парсер.ДобавитьПараметрФлагКоманды(Команда, "-r", "Устанавливает во вложенные каталоги. Если вложенный каталог не является репозиторием, то он пропускается.");
	
КонецПроцедуры // НастроитьКоманду

// Выполняет логику команды
// 
// Параметры:
//   ПараметрыКоманды - Соответствие - Соответствие ключей командной строки и их значений
//   Приложение - Модуль - Модуль менеджера приложения
//
Функция ВыполнитьКоманду(Знач ПараметрыКоманды, Знач Приложение) Экспорт
	
	Лог = Приложение.ПолучитьЛог();
	КаталогРепозитория = ПараметрыКоманды["КаталогРепозитория"];
	ФайлКаталогРепозитория = Новый Файл(КаталогРепозитория);
	Если НЕ ФайлКаталогРепозитория.Существует() ИЛИ ФайлКаталогРепозитория.ЭтоФайл() Тогда
			
		Лог.Ошибка("Каталог репозитория '%1' не существует или это файл", КаталогРепозитория);
		Возврат Приложение.РезультатыКоманд().НеверныеПараметры;
	
	КонецЕсли;
	
	КаталогИсходныхФайлов = ПараметрыКоманды["-source-dir"];
	Если Не ЗначениеЗаполнено(КаталогИсходныхФайлов) Тогда
		
		КаталогИсходныхФайлов = "src";
	
	КонецЕсли;
	
	КомандаЗапускаПриложения = Приложение.ИмяПродукта();
	Если НЕ ПараметрыКоманды["-from-path"] Тогда
		КомандаЗапускаПриложения = СтрШаблон("oscript -encoding=utf-8 ""%1""", Приложение.ПутьКИсполняемомуФайлу());
	КонецЕсли;

	КомандаPrecommtHook = СтрШаблон("#!/bin/sh
	|%1 precommit ./ -source-dir ""%2""
	|%3 precommit_bin_remove ./", КомандаЗапускаПриложения, КаталогИсходныхФайлов, КомандаЗапускаПриложения);
	Лог.Отладка("Команда pre-commit hook %2`%1`", КомандаPrecommtHook, Символы.ПС);

	Если ПараметрыКоманды["-r"] Тогда

		// установка во вложенные каталоги
		Каталоги = НайтиФайлы(КаталогРепозитория, "*");
		Для Каждого Каталог Из Каталоги Цикл

			Если НЕ Каталог.ЭтоКаталог() Тогда
				
				Продолжить;

			КонецЕсли;

			УстановитьПрекоммитВКаталогРепозитория(Каталог.ПолноеИмя, КомандаPrecommtHook);

		КонецЦикла
		
	Иначе

		УстановитьПрекоммитВКаталогРепозитория(КаталогРепозитория, КомандаPrecommtHook);

	КонецЕсли;

	// При успешном выполнении возвращает код успеха
	Возврат Приложение.РезультатыКоманд().Успех;
	
КонецФункции // ВыполнитьКоманду

Процедура УстановитьПрекоммитВКаталогРепозитория(Знач КаталогРепозитория, КомандаPrecommtHook)
	
	РепозиторийGit = Новый ГитРепозиторий();
	РепозиторийGit.УстановитьРабочийКаталог(КаталогРепозитория);
	РепозиторийGit.УстановитьНастройку("core.quotePath", "false", РежимУстановкиНастроекGit.Локально);

	// проверка каталога
	Если НЕ РепозиторийGit.ЭтоРепозиторий() Тогда
	
		Лог.Информация("Каталог '%1' не является репозиторием git", КаталогРепозитория);
		Возврат;
	
	КонецЕсли;

	// установка
	КаталогGitHook = ОбъединитьПути(КаталогРепозитория, ".git", "hooks");
	ФайлКаталогGitHook = Новый Файл(КаталогGitHook);
	Если Не ФайлКаталогGitHook.Существует() Тогда
		СоздатьКаталог(КаталогGitHook);
	КонецЕсли;

	ФайлPrecommtHook = ОбъединитьПути(КаталогGitHook, "pre-commit");

	Лог.Отладка("Создание файла pre-commit hook для %1", КаталогРепозитория);
	ТекстPrecommtHook = Новый ТекстовыйДокумент;
	ТекстPrecommtHook.УстановитьТекст(КомандаPrecommtHook);
	ТекстPrecommtHook.Записать(ФайлPrecommtHook, КодировкаТекста.UTF8NoBOM, Символы.ПС);

	Лог.Информация("Pre-commit hook для %1 создан", КаталогРепозитория);

КонецПроцедуры

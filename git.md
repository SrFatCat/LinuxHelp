
# Общие положения
## Глобальные настройки Git
```bash
git config --global user.name "Алексей Богдан"
git config --global user.email "abogdan@angelsit.ru"
```
## Создать новый репозиторий
```bash
git clone http://git.angelsit.ru/SrFatCat/testingscript.git
cd testingscript
touch README.md
git add README.md
git commit -m "add README"
git push -u origin master
```

## Отправить существующую папку
```bash
cd existing_folder
git init
git remote add origin http://git.angelsit.ru/SrFatCat/testingscript.git
git add .
git commit -m "Initial commit"
git push -u origin master
```

## Отправить существующий репозиторий Git
```bash
cd existing_repo
git remote rename origin old-origin
git remote add origin http://git.angelsit.ru/SrFatCat/testingscript.git
git push -u origin --all
git push -u origin --tags
```

## Отправить существующую папку
```bash
cd existing_folder
git init
git remote add origin http://git.angelsit.ru/SrFatCat/guard.git
git add .
git commit -m "Initial commit"
git push -u origin master
```
# Подмодули GIT
## Создание
```bash
git submodule add http://git.angelsit.ru/SrFatCat/pyosimhat.git
```

## Клонирование репы с субмодулем
```bash
git clone --recurse-submodules https://github.com/chaconinc/MainProject
# Если вы уже клонировали проект, но забыли указать --recurse-submodules
git submodule update --init --recursive

```

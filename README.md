# Update nimble version - a cli tool to update nimble version

`nimble install update_nimble_version`

This library has no dependencies other than the Nim standard library.

## About

This program searches for nimble versions recurivly and updates them.

## Usage


Update patch version
```
update_nimble_version
```

Update patch version (default)
```
update_nimble_version --patch
```


Update minor version
```
update_nimble_version --minor
```

Update imajor version
```
update_nimble_version --major
```

Get current version
```
update_nimble_version --version
```

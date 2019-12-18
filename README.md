# dotfiles

我的 dotfiles，以 [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles) 为基础，添加了中文注释并进行了必要的排版，主要适配我的 **MacOS** 开发环境。如果你想以此为基础配置属于你自己的 dotfiles，可以直接 Fork 本仓库并进行修改。

## 安装

注意：**所有风险自行承担**。

```bash
source bootstrap.sh
```

## 致谢

- [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles) - [LICENSE](licenses/mathiasbynens_dotfiles_mit)
- [natelandau/.bash_profile](https://gist.github.com/natelandau/10654137)

## 默认镜像

因为众所周知的原因，在国内通过 composer/npm/yarn 安装依赖时不配置源会很慢，极其影响开发效率。因此本库提供了默认的配置文件，如果不需要配置国内源，可以通过 `.functions` 文件中定义的重置方法进行重置。

### pip 源

如果你想查看当前 pip 使用的源，参考 [https://stackoverflow.com/questions/50100576/find-default-pip-index-url](https://stackoverflow.com/questions/50100576/find-default-pip-index-url)。

```bash
# Mac 安装 Python3 和 pip
brew install python3
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3 get-pip.py
rm get-pip.py
```

## License

[MIT](LICENSE).

git clone https://github.com/828768/828768.github.io.git blog
rm -rf /www/wwwroot/default/* && mv -f blog/* /www/wwwroot/default/
rm -rf blog && rm -f gitCloneBlog.sh

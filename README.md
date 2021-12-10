``` 
 _  /_ _  _  /____/__  _ _  _ 
/_ / //_'/_ /\   / /_'/ / //_/
                          /      hecho por nothingbutlucas
```
##Qué es esto? | What is this?

Un pequeño script para monitorizar la temperatura de tu raspberry pi

---

A little script to monitorize the temperature of your raspberry pi

## Como usarlo | How to use it? 💻


```
$ mkdir ~/.local && mkdir ~/.local/bin && cd ~/.local/bin

$ git clone https://github.com/nothingbutlucas/check-temp

$ sudo check-temp.sh
```
![imagen de una consola donde se ve el programa ejecutandose](https://telegra.ph/file/1f0cde6a8d4ce13de3206.jpg)

## Bonus

Creas un alias para ejecutarlo más cómodo (Podes usar vim, nano o el editor que quieras. Mismo usas zsh, tendras que editar el .zshrc en vez de .bashrc
Personalmente en la raspberry uso bash y el nano porque instale una version re liviana de raspberry os

---

Create an alias to make it more convenient to run (You can use vim, nano or whatever editor you want. Even if you use zsh, you will have to edit the .zshrc instead of .bashrc.
Personally on the raspberry I use bash and nano because I installed a very light version of raspberry os.

```
$ nano .bashrc
```

y agregas la siguiente linea en donde tengas tus alias

---

and add the following line where you have your aliases

```
alias check-temp='sudo /home/$USER/.local/bin/check-temp.sh'
```

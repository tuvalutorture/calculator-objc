uhhh it's like a calculator <br>
but written in objc<br>
it's also using appkit and a nib file<br>
written on mac os x 10.4<br>
do whatever you want with it i gain nothing from this shit and you won't either

also fair tip if you're running this shit on a modern mac<br>
some things you do need to know:<br>
<ul>
    <li>you need to upgrade the nib to a XIB file with `ibtool`, i refuse to further elaborate</li>
    <li>you SHOULD change the calculator display colour from beige to "default" (that way it syncs with light/dark)</li>
    <li>you need to change the sdk version (it will try to compile with a long gone 10.4 sdk. this is bad as the 10.4 sdk isnt included in xcode 27, last time i checked)</li>
</ul>
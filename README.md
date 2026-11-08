# swanctl-tray

Indicador en la barra superior de GNOME para **conectar y desconectar un túnel strongSwan (`swanctl`)** con un clic. Pensado para la VPN IKEv2 de la UPV (`UPVNET` / `ALUMNO`) con segundo factor, pero sirve para cualquier conexión de `swanctl.conf`.

*A top-bar indicator for GNOME to bring a strongSwan/`swanctl` tunnel up and down. Built for the UPV (Universitat Politècnica de València) IKEv2 VPN with MFA, but works with any `swanctl.conf` connection.*

- Icono según el estado: desconectada, conectando, conectada, error.
- Muestra la IP virtual del túnel en el menú.
- Notificaciones: "aprueba el push de Authenticator", conectada, fallo (con causa probable).
- **No guarda ni lee ningún secreto.** Solo ejecuta `sudo -n swanctl ...`.

## Por qué existe

La VPN de la UPV con segundo factor (Microsoft Authenticator) no funciona con el cliente `vpnc` de NetworkManager: el grupo antiguo `soloupv` está en desuso y no dispara el push. La wiki de la UPV propone strongSwan + `swanctl` desde terminal, y los plugins gráficos de NetworkManager no soportan esta combinación (PSK en el servidor + EAP-MSCHAPv2 en el usuario). Este indicador pone una interfaz gráfica sobre ese flujo.

## Requisitos

- Ubuntu 24.04+ con GNOME (la extensión `ubuntu-appindicators` viene activa por defecto).
- `sudo apt install strongswan-swanctl charon-systemd libcharon-extra-plugins libstrongswan-extra-plugins gir1.2-ayatanaappindicator3-0.1 libnotify-bin`
- **Ubuntu 24.04:** el metapaquete `strongswan` instala el demonio antiguo (`strongswan-starter`). Para `swanctl` necesitas `charon-systemd`:
  ```
  sudo systemctl disable --now strongswan-starter
  sudo apt install charon-systemd
  sudo systemctl enable --now strongswan
  ```

## Instalación

1. **Perfil de la VPN.** Copia `examples/swanctl.conf.example` a `/etc/swanctl/swanctl.conf` con permisos `600`, y rellena tu usuario, la clave PSK del portal de autogestión de la UPV ("Clave para la VPN", fila `UPVNET`/`ALUMNO`) y tu contraseña.
   ```
   sudo install -m 600 -o root -g root examples/swanctl.conf.example /etc/swanctl/swanctl.conf
   sudoedit /etc/swanctl/swanctl.conf
   ```
2. **`sudo` sin contraseña para `swanctl`** (ver el aviso de seguridad en el fichero):
   ```
   sudo visudo -f /etc/sudoers.d/swanctl-tray     # contenido de examples/sudoers.d/swanctl-tray
   ```
3. **El indicador:**
   ```
   ./install.sh
   swanctl-tray &
   ```
   Se instala en `~/.local/bin` y arranca solo al iniciar sesión.

Si tu conexión no se llama `UPVNET` con hijo `net`, edita `~/.config/swanctl-tray/config.ini`.

## Seguridad

- `NOPASSWD` para `swanctl` da a cualquier proceso de tu usuario control de root sobre el demonio IPsec (puede cargar y leer credenciales). Úsalo solo en un equipo de confianza.
- `/etc/swanctl/swanctl.conf` contiene tus secretos en texto plano: déjalo en `600`, propiedad de root, y **no lo subas a git** (está en `.gitignore`).

## Limitaciones conocidas

- El perfil de la UPV enruta por el túnel `172.16.0.0/12` y `192.168.0.0/16`, que pueden solaparse con tus redes locales (Docker, libvirt…) mientras esté activo.
- strongSwan intenta configurar el DNS de la UPV con `resolvconf` y puede fallar con `systemd-resolved`; la wiki de la UPV propone un script `updown` con `resolvectl`.
- Solo probado en Ubuntu 24.04 / GNOME 46 / Wayland.

## Licencia

MIT.

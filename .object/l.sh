#!/data/data/com.termux/files/usr/bin/bash

################################################################
# Script Name : Metasploit-Termux Legacy Installer
# Target      : Android 4.4 - 6.0
# Author      : Raj Aryan (h4ck3r0)
# GitHub      : https://github.com/h4ck3r0/Metasploit-termux
################################################################

PREFIX="/data/data/com.termux/files/usr"
PG_DATA="$PREFIX/var/lib/postgresql"
LOG_FILE="$HOME/install_legacy.log"

RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

banner() {
    clear
    echo -e "${RED}"
    echo -e " ███████ ▓█████▄▄▄█████▓ █    ██  ██▓███  "
    echo -e "▒██    ▒ ▓█   ▀▓  ██▒ ▓▒ ██  ▓██▒▓██░  ██▒"
    echo -e "░ ▓██▄   ▒███  ▒ ▓██░ ▒░▓██  ▒██░▓██░ ██▓▒"
    echo -e "  ▒   ██▒▒▓█  ▄░ ▓██▓ ░ ▓▓█  ░██░▒██▄█▓▒ ▒"
    echo -e "▒██████▒▒░▒████▒ ▒██▒ ░ ▒▒█████▓ ▒██▒ ░  ░"
    echo -e "▒ ▒▓▒ ▒ ░░░ ▒░ ░ ▒ ░░   ░▒▓▒ ▒ ▒ ▒▓▒░ ░  ░"
    echo -e "░ ░▒  ░ ░ ░ ░  ░   ░    ░░▒░ ░ ░ ░▒ ░     "
    echo -e "░  ░  ░     ░    ░       ░░░ ░ ░ ░░       "
    echo -e "     ░     ░  ░           ░           ${RESET}"
    echo -e "${BLUE} ####################################################${RESET}"
    echo -e "${YELLOW}  Legacy Install — Android 4.4 - 6.0${RESET}"
    echo -e "${YELLOW}  Author : Raj Aryan (h4ck3r0)${RESET}"
    echo -e "${BLUE} ####################################################${RESET}"
    echo -e "${CYAN}  Logs: ~/install_legacy.log${RESET}\n"
}

run_task() {
    local msg="$1"
    local cmd="$2"
    echo -ne "${YELLOW}[...]${RESET} $msg"
    eval "$cmd" >> "$LOG_FILE" 2>&1
    if [ $? -eq 0 ]; then
        echo -e "\r${GREEN}[DONE]${RESET} $msg"
    else
        echo -e "\r${RED}[FAIL]${RESET} $msg (Check install_legacy.log)"
        exit 1
    fi
}

# ─────────────────────────────────────────────
# Get latest MSF version from GitHub
# ─────────────────────────────────────────────
get_latest_msf_version() {
    local ver
    ver=$(curl -s "https://api.github.com/repos/rapid7/metasploit-framework/releases/latest" \
        | grep '"tag_name"' \
        | sed 's/.*"tag_name": *"v\{0,1\}\([^"]*\)".*/\1/')

    # Fallback if curl/API fails
    if [ -z "$ver" ]; then
        ver="6.4.0"
        echo -e "${YELLOW}[WARN] Could not fetch latest MSF version, using fallback: $ver${RESET}"
    else
        echo -e "${GREEN}[INFO] Latest Metasploit version: $ver${RESET}"
    fi
    echo "$ver"
}

# ─────────────────────────────────────────────
# Detect installed Ruby version dynamically
# ─────────────────────────────────────────────
get_ruby_gem_path() {
    ruby -e "puts Gem.default_dir" 2>/dev/null || echo "$PREFIX/lib/ruby/gems/3.4.0"
}

install_deps() {
    # Remove any conflicting extra source lists (legacy Termux issue)
    rm -f "$PREFIX/etc/apt/sources.list.d/"* 2>/dev/null || true

    run_task "Purging old Ruby installation" "
        apt purge ruby -y 2>/dev/null || true
        rm -rf $PREFIX/lib/ruby/gems 2>/dev/null || true
    "

    run_task "Upgrading system packages" \
        "pkg upgrade -y -o Dpkg::Options::=\"--force-confnew\""

    run_task "Installing core dependencies" "
        pkg install -y python autoconf bison clang coreutils curl findutils \
        apr apr-util postgresql openssl readline libffi libgmp libpcap \
        libsqlite libgrpc libtool libxml2 libxslt ncurses make ncurses-utils \
        git wget unzip zip tar termux-tools termux-elf-cleaner pkg-config \
        ruby libiconv binutils zlib libyaml liblzma \
        -o Dpkg::Options::=\"--force-confnew\" --allow-change-held-packages
    "
}

fix_nokogiri() {
    local NOKO_VERSION="1.18.10"
    local RUBY_GEM_DIR
    RUBY_GEM_DIR=$(get_ruby_gem_path)

    run_task "Clearing old Nokogiri cache" "
        rm -rf ~/.gem/gems/nokogiri* &&
        rm -rf ~/.gem/extensions/*
    "

    # Non-fatal update
    echo -ne "${YELLOW}[...]${RESET} Updating RubyGems (non-fatal)"
    gem update --system >> "$LOG_FILE" 2>&1 && \
        echo -e "\r${GREEN}[DONE]${RESET} Updating RubyGems (non-fatal)" || \
        echo -e "\r${YELLOW}[SKIP]${RESET} RubyGems update skipped (continuing anyway)"

    run_task "Installing mini_portile2" "gem install mini_portile2 -v 2.8.5"

    # BUG FIX: double quotes so ${PREFIX} expands properly
    run_task "Installing Nokogiri ${NOKO_VERSION} (Gumbo disabled)" "
        gem install nokogiri -v ${NOKO_VERSION} -- \
          --use-system-libraries \
          --disable-gumbo \
          --with-xml2-include=${PREFIX}/include/libxml2 \
          --with-xml2-lib=${PREFIX}/lib
    "

    rm -rf ~/.gem/gems/nokogiri-${NOKO_VERSION}/ext/nokogiri/gumbo* 2>/dev/null || true
}

install_msf() {
    local MSF_VERSION
    MSF_VERSION=$(get_latest_msf_version)
    local MSF_URL="https://github.com/rapid7/metasploit-framework/archive/${MSF_VERSION}.tar.gz"
    local MSF_DIR="$HOME/metasploit-framework"

    # Remove old installation
    echo -e "${YELLOW}[*] Removing old Metasploit (if any)...${RESET}"
    rm -rf "$MSF_DIR" 2>/dev/null || true

    run_task "Downloading Metasploit ${MSF_VERSION}" \
        "curl -L -o $HOME/msf.tar.gz $MSF_URL"

    run_task "Extracting archive" \
        "tar -xf $HOME/msf.tar.gz -C $HOME && \
         mv $HOME/metasploit-framework-${MSF_VERSION} $MSF_DIR && \
         rm -f $HOME/msf.tar.gz"

    cd "$MSF_DIR" || exit 1

    run_task "Installing Bundler" "gem install bundler"

    fix_nokogiri

    # BUG FIX: double quotes so ${PREFIX} expands properly
    run_task "Configuring Bundle settings" "
        bundle config set --local force_ruby_platform true &&
        bundle config set build.nokogiri \"--use-system-libraries --disable-gumbo --with-xml2-include=${PREFIX}/include/libxml2 --with-xml2-lib=${PREFIX}/lib\" &&
        bundle config set build.pg --with-pg-config=${PREFIX}/bin/pg_config
    "

    run_task "Installing Framework Gems (this takes a while...)" \
        "bundle install -j$(nproc)"
}

setup_postgresql() {
    run_task "Initializing PostgreSQL" "
        mkdir -p $PG_DATA &&
        [ ! -d $PG_DATA/base ] && initdb $PG_DATA || true
    "

    run_task "Starting PostgreSQL" \
        "pg_ctl -D $PG_DATA -l $PG_DATA/logfile start"
}

setup_binaries() {
    local MSF_DIR="$HOME/metasploit-framework"

    # Remove old symlinks/scripts
    rm -f "$PREFIX/bin/msfconsole" "$PREFIX/bin/msfvenom" 2>/dev/null || true

    cat > "$PREFIX/bin/msfconsole" << WRAPPER_EOF
#!/data/data/com.termux/files/usr/bin/bash
PG_DATA="$PG_DATA"
if [ -f "\$PG_DATA/postmaster.pid" ]; then
    pg_ctl -D "\$PG_DATA" status > /dev/null 2>&1 || rm "\$PG_DATA/postmaster.pid"
fi
pg_ctl -D "\$PG_DATA" -l "\$PG_DATA/logfile" start > /dev/null 2>&1
cd "$MSF_DIR"
./msfconsole "\$@"
WRAPPER_EOF

    cat > "$PREFIX/bin/msfvenom" << WRAPPER_EOF
#!/data/data/com.termux/files/usr/bin/bash
cd "$MSF_DIR"
./msfvenom "\$@"
WRAPPER_EOF

    chmod +x "$PREFIX/bin/msfconsole" "$PREFIX/bin/msfvenom"

    run_task "Running ELF cleaner on pg gem" "
        termux-elf-cleaner $PREFIX/lib/ruby/gems/*/gems/pg-*/lib/pg_ext.so
    " 2>/dev/null || true
}

# ─────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────
banner
> "$LOG_FILE"

install_deps
install_msf
setup_postgresql
setup_binaries

echo -e "\n${GREEN}✔ Legacy installation complete!${RESET}"
echo -e "${YELLOW}Usage: ${GREEN}msfconsole${RESET}\n"

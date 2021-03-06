function msg() {
    echo -e "\e[1;32m$*\e[0m"
}
function register_clang_version() {
    local version=$1
    if [[ -d /usr/lib/llvm-$version/bin ]];then
        CMDx=(--install /usr/bin/clang clang /usr/lib/llvm-$version/bin/clang 500)
        for ListCmds in $(ls /usr/lib/llvm-$version/bin)
        do
            [[ "$ListCmds" != "clang" ]] && CMDx+=(--slave /usr/bin/$ListCmds $ListCmds /usr/lib/llvm-$version/bin/$ListCmds)
        done
    fi
    update-alternatives ${CMDx[@]}
    [[ -d /usr/lib/llvm-$version/bin ]] && export PATH="/usr/lib/llvm-$version/bin:${PATH}"
    [[ -d /usr/lib/llvm-$version/lib ]] && export LD_LIBRARY_PATH="/usr/lib/llvm-$version/lib:${LD_LIBRARY_PATH}"
}
apt-get -y install clang-11 lld-11 linux-tools-common linux-tools-azure xxhash patchelf elfutils wget ccache
# register_clang_version 11
TotalFail="0"
function getclang()
{
    Fail="N"
    Ver="${@}"
    msg "try clone clang $Ver"
    wget -q $(curl https://raw.githubusercontent.com/ZyCromerZ/Clang/main/Clang-$Ver-link.txt 2>/dev/null) -O "ZyC-Clang.tar.gz" || Fail="Y"
    if [[ "${Fail}" == "N" ]];then
        mkdir $(pwd)/extracted-clang
        tar -xf ZyC-Clang.tar.gz -C "$(pwd)/extracted-clang"
        
        CMDx=(--install /usr/bin/clang clang $(pwd)/extracted-clang/bin/clang 500)
        for ListCmds in $(ls $(pwd)/extracted-clang/bin)
        do
            [[ "$ListCmds" != "clang" ]] && CMDx+=(--slave /usr/bin/$ListCmds $ListCmds $(pwd)/extracted-clang/bin/$ListCmds)
        done
        update-alternatives ${CMDx[@]}

        [[ -d $(pwd)/extracted-clang/bin ]] && export PATH="$(pwd)/extracted-clang/bin:${PATH}"
        [[ -d $(pwd)/extracted-clang/lib ]] && export LD_LIBRARY_PATH="$(pwd)/extracted-clang/lib:${LD_LIBRARY_PATH}"

    else
        TotalFail=$(($TotalFail+1))
        msg "clone clang $Ver fail"
        sleep 1s
        if [[ "${TotalFail}" -le "10" ]];then
            getclang $Ver
        else
            register_clang_version 11
        fi
    fi
}
getclang "$1"
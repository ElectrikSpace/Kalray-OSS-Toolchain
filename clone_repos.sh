git clone https://github.com/kalray/binutils.git --depth 1
cd binutils && git checkout coolidge && cd ..

git clone https://github.com/kalray/gcc.git --depth 1
cd gcc && git checkout coolidge && cd ..

git clone https://github.com/kalray/newlib.git --depth 1
cd newlib && git checkout coolidge && cd ..

git clone https://github.com/kalray/qemu.git --depth 1
cd qemu && git checkout coolidge-6.1 && cd ..

#git clone https://github.com/kalray/llvm-project.git --depth 1
#cd llvm-project && git checkout coolidge && cd ..

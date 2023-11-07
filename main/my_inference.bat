@echo off
setlocal enabledelayedexpansion

REM Set variables
set PARTITION=Zoetrope
set INPUT_VIDEO=%1
set FORMAT=%2
set FPS=%3
set CKPT=%4

set GPUS=1
set JOB_NAME=inference_%INPUT_VIDEO%

set GPUS_PER_NODE=!GPUS!
set CPUS_PER_TASK=4
set SRUN_ARGS=

set IMG_PATH=..\demo\images\%INPUT_VIDEO%
set SAVE_DIR=..\demo\results\%INPUT_VIDEO%

REM Video to images
mkdir "%IMG_PATH%"
mkdir "%SAVE_DIR%"
ffmpeg -i ..\demo\videos\%INPUT_VIDEO%.%FORMAT% -f image2 -vf fps=!FPS!/1 -q:v 0 "%IMG_PATH%\%%06d.jpg"

set /a end_count=0
for /r "%IMG_PATH%" %%f in (*) do set /a end_count+=1
echo !end_count!

REM Inference
set PYTHONPATH=%~dp0\..;%PYTHONPATH%
REM python inference.py --num_gpus !GPUS_PER_NODE! --exp_name output\demo_!JOB_NAME! --pretrained_model !CKPT! --agora_benchmark agora_model --img_path !IMG_PATH! --start 1 --end !end_count! --output_folder !SAVE_DIR! --show_verts --show_bbox --save_mesh
python inference.py --num_gpus !GPUS_PER_NODE! --exp_name output\demo_!JOB_NAME! --pretrained_model !CKPT! --agora_benchmark agora_model --img_path !IMG_PATH! --start 1 --end !end_count! --output_folder !SAVE_DIR! --show_verts --show_bbox
REM python inference.py --num_gpus !GPUS_PER_NODE! --exp_name output\demo_!JOB_NAME! --pretrained_model !CKPT! --agora_benchmark agora_model --img_path !IMG_PATH! --start 1 --end !end_count! --output_folder !SAVE_DIR! --show_verts --show_bbox --save_mesh --multi_person --iou_thr 0.2 --bbox_thr 20

REM Images to video
ffmpeg -i "%SAVE_DIR%\img\%%06d.jpg" -c:v libx264 -r !FPS! -pix_fmt yuv420p ..\demo\results\%INPUT_VIDEO%.mp4
endlocal

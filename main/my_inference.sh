# #!/usr/bin/env bash
set -x

PARTITION=Zoetrope

INPUT_VIDEO=$1
FORMAT=$2
FPS=$3
CKPT=$4

GPUS=1
JOB_NAME=inference_${INPUT_VIDEO}

GPUS_PER_NODE=$((${GPUS}<8?${GPUS}:8))
CPUS_PER_TASK=4 # ${CPUS_PER_TASK:-2}
SRUN_ARGS=${SRUN_ARGS:-""}

IMG_PATH=../demo/images/${INPUT_VIDEO}
SAVE_DIR=../demo/results/${INPUT_VIDEO}

# video to images
mkdir $IMG_PATH
mkdir $SAVE_aptDIR
ffmpeg -i ../demo/videos/${INPUT_VIDEO}.${FORMAT} -f image2 -vf fps=${FPS}/1 -qscale 0 ../demo/images/${INPUT_VIDEO}/%06d.jpg 

end_count=$(find "$IMG_PATH" -type f | wc -l)
echo $end_count

# inference
PYTHONPATH="$(dirname $0)/..":$PYTHONPATH \

python inference.py \
--num_gpus ${GPUS_PER_NODE} \
--exp_name output/demo_${JOB_NAME} \
--pretrained_model ${CKPT} \
--agora_benchmark agora_model \
--img_path ${IMG_PATH} \
--start 1 \
--end  $end_count \
--output_folder ${SAVE_DIR} \
--show_verts \
--show_bbox \
--save_mesh \
# --multi_person \
# --iou_thr 0.2 \
# --bbox_thr 20


# images to video
ffmpeg -y -f image2 -r ${FPS} -i ${SAVE_DIR}/img/%06d.jpg -vcodec mjpeg -qscale 0 -pix_fmt yuv420p ../demo/results/${INPUT_VIDEO}.mp4

ffmpeg -framerate 30 -i ../demo/results/正手攻球-完美动作-60fps/img/%06d.jpg -c:v libx264 -r 30 -pix_fmt yuv420p ../demo/results/正手攻球-完美动作-60fps.mp4


ffmpeg -y -f image2 -r 30 -i ../demo/results/正手攻球-完美动作-60fps/img/%06d.jpg -vcodec mjpeg -qscale 0 -pix_fmt yuv420p ../demo/results/正手攻球-完美动作-60fps.mp4

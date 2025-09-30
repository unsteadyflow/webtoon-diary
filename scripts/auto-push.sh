#!/bin/bash

# 자동 푸시 스크립트
# 사용법: ./scripts/auto-push.sh "커밋 메시지"

if [ $# -eq 0 ]; then
    echo "사용법: ./scripts/auto-push.sh \"커밋 메시지\""
    exit 1
fi

COMMIT_MSG="$1"

echo "🔄 자동 푸시 시작..."
echo "📝 커밋 메시지: $COMMIT_MSG"

# 모든 변경사항 추가
git add .

# 커밋
git commit -m "$COMMIT_MSG"

# 푸시
git push origin main

if [ $? -eq 0 ]; then
    echo "✅ 성공적으로 푸시되었습니다!"
    echo "🔗 GitHub 저장소: https://github.com/unsteadyflow/webtoon-diary"
else
    echo "❌ 푸시에 실패했습니다."
    exit 1
fi

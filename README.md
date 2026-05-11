## 소개
앱스토어에 출시된 생활 기록 앱입니다.
사용자는 배변 기록을 캘린더에 저장하고, 누적 기록을 바탕으로 월간 리포트를 확인하며, 효과가 좋았던 제품을 추천/투표할 수 있습니다.

## 주요 기능
- 배변 기록 저장/조회/변경/삭제
- 캘린더 기반 기록 시각화
- 요일/시간대/유형별 월간 리포트
- 제품 추천 및 투표
- 이벤트 기간 캘린더 기록 아이콘 시즌 테마 적용
- 원격 이미지 로딩 및 이미지 확대 보기
- AWS Cognito + DynamoDB 기반 사용자별 데이터 저장

## 스크린샷
<img width="24%" alt="iphone_app_store_3" src="https://github.com/user-attachments/assets/6c021c14-be88-4251-8c66-eaae631f9cd9" />
<img width="24%" alt="iphone_app_store_2" src="https://github.com/user-attachments/assets/ceee6848-faf3-4f5f-94e0-2cf1c9034a3a" />
<img width="24%" alt="iphone_app_store_1" src="https://github.com/user-attachments/assets/92aad8b0-0fca-4cc8-8a73-03554846963a" />
<img width="24%" alt="iphone_app_store_4" src="https://github.com/user-attachments/assets/fa32ef64-f16e-49b4-af6b-0a060fd80fd3" />

## 기술 스택
- Swift
- SwiftUI
- AWS Cognito, AWS DynamoDB
- Kingfisher

## 기술적 고민
### 추천 수 동시성 처리
여러 사용자가 동시에 제품을 추천/취소할 수 있기 때문에 DynamoDB ObjectMapper 저장 방식 대신 low-level updateItem을 사용했습니다. if_not_exists와 conditionExpression을 활용해 추천 수를 원자적으로 증가/감소시키고, 0 미만으로 내려가지 않도록 방어했습니다.

### 사용자별 기록 저장 구조
배변 기록은 userId + date 복합 키로 저장하여 사용자별 날짜 기반 조회가 가능하도록 설계했습니다.

package chuchu.runnerway.runningRecord.model.service;

import chuchu.runnerway.common.util.MemberInfo;
import chuchu.runnerway.course.entity.Course;
import chuchu.runnerway.course.model.repository.OfficialCourseRepository;
import chuchu.runnerway.member.domain.Member;
import chuchu.runnerway.member.repository.MemberRepository;
import chuchu.runnerway.ranking.entity.Ranking;
import chuchu.runnerway.ranking.model.repository.RankingRepository;
import chuchu.runnerway.runningRecord.dto.request.RecordRegistRequestDto;
import chuchu.runnerway.runningRecord.dto.request.RecordUpdateCommentRequestDto;
import chuchu.runnerway.runningRecord.dto.request.RecordUpdatePictureRequestDto;
import chuchu.runnerway.runningRecord.dto.response.RecordDetailResponseDto;
import chuchu.runnerway.runningRecord.dto.response.RecordMonthData;
import chuchu.runnerway.runningRecord.dto.response.RecordResponseDto;
import chuchu.runnerway.runningRecord.entity.PersonalImage;
import chuchu.runnerway.runningRecord.entity.RecommendationLog;
import chuchu.runnerway.runningRecord.entity.RunningRecord;
import chuchu.runnerway.runningRecord.mapper.RunningRecordMapper;
import chuchu.runnerway.runningRecord.model.repository.PersonalImageRepository;
import chuchu.runnerway.runningRecord.model.repository.RecommendationLogRepository;
import chuchu.runnerway.runningRecord.model.repository.RunningRecordRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.CacheManager;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Time;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.*;

@Service
@RequiredArgsConstructor
@Slf4j
public class RunningRecordServiceImpl implements RunningRecordService{

    private final RunningRecordRepository runningRecordRepository;
    private final RunningRecordMapper runningRecordMapper;
    private final MemberRepository memberRepository;
    private final PersonalImageRepository personalImageRepository;
    private final RecommendationLogRepository recommendationLogRepository;

    private final RankingRepository rankingRepository;

    private final CacheManager cacheManager;
    private final OfficialCourseRepository officialCourseRepository;

    @Override
    public List<RecordResponseDto> getRecords(int year, int month, Integer day) {
        Long memberId = MemberInfo.getId();
        List<RunningRecord> runningRecords = runningRecordRepository.findByDate(year, month, day, memberId);
        if(runningRecords.isEmpty()) {
            return null;
        }

        return runningRecordMapper.toRecordResponseDtoList(runningRecords);
    }

    @Transactional
    @Override
    public RecordDetailResponseDto getRecord(Long recordId) {
        RunningRecord runningRecord = runningRecordRepository.findById(recordId)
                .orElse(null);
        if(runningRecord == null) return null;


        return runningRecordMapper.toRecordDetailResponseDto(runningRecord);
    }

    @Override
    public RecordMonthData getAnalysisRecord(int year, int month) {
        Long memberId = MemberInfo.getId();
        Map<String, Object> result = runningRecordRepository.getRecordMonthData(year, month, memberId)
                .orElseThrow(NoSuchElementException::new);
        if(result.get("totalScore") == null){
            return new RecordMonthData(
                    0,
                    0,
                    "00:00:00",
                    0
            );
        }

        long time = ((Number) result.get("totalScore")).longValue();
        long hours = time / 3600;
        long minutes = (time % 3600) / 60;
        long seconds = time % 60;
        String formattedTotalScore = String.format("%02d:%02d:%02d", hours, minutes, seconds);

        double averageFace = ((Number) result.get("averageFace")).doubleValue();
        int fMinute = (int) averageFace;
        int fSecond = (int) Math.round((averageFace - fMinute) * 100);
        int second = fMinute*60 + fSecond;
        second /= ((Number) result.get("totalCount")).intValue();
        averageFace = 0.0;
        averageFace += (int)((double) second / 60);
        averageFace += ((double) second % 60) / 100;


        return new RecordMonthData(
                ((Number) result.get("totalDistance")).doubleValue(),
                Math.round(averageFace * 100) / 100.0,
                formattedTotalScore,
                ((Number) result.get("totalCalorie")).doubleValue()
        );
    }

    @Transactional
    @Override
    public Map<String, Object> registRecord(RecordRegistRequestDto requestDto) {
        Long memberId = MemberInfo.getId();
        Member member = memberRepository.findById(memberId)
                        .orElseThrow(NoSuchElementException::new);

        RunningRecord runningRecord = runningRecordMapper.toRegistRunningRecordDto(requestDto);
        runningRecord.registMember(member);
        runningRecord = runningRecordRepository.save(runningRecord);

        PersonalImage image = new PersonalImage();
        image.createPersonalImage(runningRecord, requestDto);
        personalImageRepository.save(image);

        Map<String, Object> data = new HashMap<>();
        data.put("recordId", runningRecord.getRecordId());

        Course course = officialCourseRepository.findByCourseId(runningRecord.getCourse().getCourseId())
                        .orElseThrow(NoSuchElementException::new);
        RecommendationLog log = new RecommendationLog(course, member, course.getLevel(), course.getAverageSlope());
        recommendationLogRepository.save(log);
        // 코스 랭킹 등록
        return data;
    }

    @Transactional
    @Override
    public void updateRecordPicture(RecordUpdatePictureRequestDto requestDto) {
        RunningRecord runningRecord = runningRecordRepository.findByRecordId(requestDto.getRecordId())
                .orElseThrow(NoSuchElementException::new);

        PersonalImage personalImage = personalImageRepository.findByRecordId(requestDto.getRecordId())
                .orElseThrow(NoSuchElementException::new);
        personalImage.updatePersonalImage(runningRecord, requestDto);

        personalImageRepository.save(personalImage);
    }

    @Override
    public void updateRecordComment(RecordUpdateCommentRequestDto requestDto) {
        RunningRecord runningRecord = runningRecordRepository.findByRecordId(requestDto.getRecordId())
                        .orElseThrow(NoSuchElementException::new);

        runningRecord.updateRunningRecord(requestDto);
        runningRecordRepository.save(runningRecord);
    }



    
}

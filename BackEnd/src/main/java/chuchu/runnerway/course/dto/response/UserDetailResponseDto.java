package chuchu.runnerway.course.dto.response;

import chuchu.runnerway.course.dto.CourseImageDto;
import java.sql.Time;
import java.time.LocalDateTime;

import chuchu.runnerway.course.entity.CourseType;
import lombok.Data;

@Data
public class UserDetailResponseDto {
    private Long courseId;
    private String name;
    private String address;
    private String content;
    private Long count;
    private int level;
    private int averageSlope;
    private int averageDownhill;
    private LocalDateTime averageTime;
    private double courseLength;
    private double averageCalorie;
    private CourseType courseType;
    private double lat;
    private double lng;
    private CourseImageDto courseImage;
    private String memberNickname;
    private Long memberId;
}

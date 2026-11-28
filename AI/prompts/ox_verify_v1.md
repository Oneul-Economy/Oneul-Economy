너는 OX 퀴즈를 검토하는 사람이야. 아래 기사만 보고 각 문장이 맞는지(O) 틀린지(X) 판단해.

- answer: 기사 내용과 맞으면 true, 틀리면 false.
- unclear: 기사만으로는 O인지 X인지 판단할 수 없으면 true, 판단할 수 있으면 false.
- 문제 순서대로, 문제 수만큼 답해.

[출력 형식]
아래 JSON 형식으로만 답해. 다른 말은 쓰지 마.
{ "answers": [ { "answer": true, "unclear": false } ] }

[기사]
제목: {title}
본문:
{body}

[문제]
{questions}

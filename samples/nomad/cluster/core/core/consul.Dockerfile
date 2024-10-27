FROM hashicorp/consul:1.19.2

CMD [ "agent", "-dev", "-client=0.0.0.0" ]

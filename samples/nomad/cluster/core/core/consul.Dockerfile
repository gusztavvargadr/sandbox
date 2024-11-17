FROM hashicorp/consul:1.20.1

CMD [ "agent", "-dev", "-client=0.0.0.0" ]

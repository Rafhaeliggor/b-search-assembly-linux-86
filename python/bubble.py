def bubble(array):
	len_array = len(array)
	for i in range(len_array):
		for j in range(len_array-i-1):
			if array[j] > array[j+1]:
				array[j], array[j+1] = array[j+1], array[j]
	return array
def main():
	numbers = []
	print('Define a number')
	while True:
		inp = (input('>'))
		if inp != "":
			num = int(inp)
			numbers.append(num)
		else:
			break
	print(numbers)
	print(bubble(numbers))

		
if __name__ == "__main__":
	main()
